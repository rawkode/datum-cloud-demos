// datumctl-zones: a minimal datumctl plugin.
//
// Adds `datumctl zones summary`, which counts the DNS zones in the current
// project, and `datumctl zones context`, which prints what datumctl injected.
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"sort"

	"github.com/spf13/cobra"
	"go.datum.net/datumctl/plugin"
)

var manifest = plugin.Manifest{
	Name:          "zones",
	Version:       "v0.1.0",
	Description:   "Summarise DNS zones in the current project",
	APIVersion:    1,
	MinAPIVersion: 1,
}

// zoneList is the subset of a DNSZoneList we care about.
type zoneList struct {
	Items []struct {
		Metadata struct {
			Name string `json:"name"`
		} `json:"metadata"`
		Spec struct {
			DomainName string `json:"domainName"`
		} `json:"spec"`
		Status struct {
			Conditions []struct {
				Type   string `json:"type"`
				Status string `json:"status"`
			} `json:"conditions"`
		} `json:"status"`
	} `json:"items"`
}

func main() {
	// Must run before cobra: datumctl calls the binary with --plugin-manifest
	// at install time to read name, version and API compatibility.
	plugin.ServeManifest(manifest)

	root := plugin.NewRootCmd("zones", "Summarise DNS zones in the current project")
	root.SilenceUsage = true

	root.AddCommand(&cobra.Command{
		Use:   "context",
		Short: "Show the context datumctl injected into this plugin",
		RunE: func(cmd *cobra.Command, _ []string) error {
			ctx := plugin.Context()
			fmt.Fprintf(cmd.OutOrStdout(), "Org:                %s\n", ctx.Org)
			fmt.Fprintf(cmd.OutOrStdout(), "Project:            %s\n", ctx.Project)
			fmt.Fprintf(cmd.OutOrStdout(), "API host:           %s\n", ctx.APIHost)
			fmt.Fprintf(cmd.OutOrStdout(), "Session:            %s\n", ctx.Session)
			fmt.Fprintf(cmd.OutOrStdout(), "Plugin API version: %d\n", ctx.PluginAPIVersion)
			fmt.Fprintf(cmd.OutOrStdout(), "Credentials helper: %s\n", ctx.CredentialsHelper)
			return nil
		},
	})

	root.AddCommand(&cobra.Command{
		Use:   "summary",
		Short: "Count DNS zones and report how many are ready",
		RunE: func(cmd *cobra.Command, _ []string) error {
			ctx := plugin.Context()
			project, _ := cmd.Flags().GetString("project")
			output, _ := cmd.Flags().GetString("output")

			if project == "" {
				return fmt.Errorf("no project in scope; run 'datumctl ctx use <org>/<project>' or pass --project")
			}
			if ctx.CredentialsHelper == "" {
				return fmt.Errorf("DATUM_CREDENTIALS_HELPER is not set; run this as 'datumctl zones summary'")
			}

			// Fresh token per request. datumctl's helper handles refresh.
			token, err := plugin.Token()
			if err != nil {
				return err
			}

			url := fmt.Sprintf(
				"https://%s/apis/resourcemanager.miloapis.com/v1alpha1/projects/%s/control-plane"+
					"/apis/dns.networking.miloapis.com/v1alpha1/namespaces/default/dnszones",
				ctx.APIHost, project)

			req, err := http.NewRequestWithContext(cmd.Context(), http.MethodGet, url, nil)
			if err != nil {
				return err
			}
			req.Header.Set("Authorization", "Bearer "+token)
			req.Header.Set("Accept", "application/json")

			resp, err := http.DefaultClient.Do(req)
			if err != nil {
				return fmt.Errorf("list dnszones: %w", err)
			}
			defer resp.Body.Close()
			if resp.StatusCode != http.StatusOK {
				return fmt.Errorf("list dnszones: API returned %s", resp.Status)
			}

			var zones zoneList
			if err := json.NewDecoder(resp.Body).Decode(&zones); err != nil {
				return fmt.Errorf("decode response: %w", err)
			}

			ready := 0
			names := make([]string, 0, len(zones.Items))
			for _, z := range zones.Items {
				names = append(names, z.Spec.DomainName)
				for _, c := range z.Status.Conditions {
					if c.Type == "Ready" && c.Status == "True" {
						ready++
					}
				}
			}
			sort.Strings(names)

			if output == "json" {
				return json.NewEncoder(cmd.OutOrStdout()).Encode(map[string]any{
					"project": project, "total": len(zones.Items), "ready": ready, "domains": names,
				})
			}
			fmt.Fprintf(cmd.OutOrStdout(), "Project: %s\nZones:   %d\nReady:   %d\n", project, len(zones.Items), ready)
			for _, n := range names {
				fmt.Fprintf(cmd.OutOrStdout(), "  - %s\n", n)
			}
			return nil
		},
	})

	if err := root.Execute(); err != nil {
		// Exit non-zero so `datumctl zones ...` propagates the failure.
		os.Exit(1)
	}
}
