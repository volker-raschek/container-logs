package main

import (
	"context"
	"io"
	"os"
	"strings"

	"git.cryptic.systems/volker.raschek/dockerutils"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"github.com/spf13/cobra"
)

var (
	version string

	allContainers bool

	ids       []string
	names     []string
	rawLabels []string

	printStderr bool
	printStdout bool
)

func main() {
	rootCmd := &cobra.Command{
		Use:     "container-log",
		Short:   "Write logs of containers on stdout",
		Version: version,
		RunE:    runRootCmd,
	}
	rootCmd.Flags().BoolVarP(&allContainers, "all", "a", false, "All containers, including those that are switched off or aborted")
	rootCmd.Flags().StringArrayVarP(&ids, "id", "i", make([]string, 0), "Select container by id")
	rootCmd.Flags().StringArrayVarP(&names, "name", "n", make([]string, 0), "Select container by name")
	rootCmd.Flags().StringArrayVarP(&rawLabels, "label", "l", make([]string, 0), "Select container by labels")

	completionCmd := &cobra.Command{
		Use:       "completion [bash|zsh|fish|powershell]",
		Short:     "Generate completion script",
		ValidArgs: []string{"bash", "zsh", "fish", "powershell"},
		Args:      cobra.ExactValidArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			switch args[0] {
			case "bash":
				cmd.Root().GenBashCompletion(os.Stdout)
			case "zsh":
				cmd.Root().GenZshCompletion(os.Stdout)
			case "fish":
				cmd.Root().GenFishCompletion(os.Stdout, true)
			}
		},
	}
	rootCmd.AddCommand(completionCmd)

	rootCmd.Execute()
}

func runRootCmd(cmd *cobra.Command, args []string) error {
	dockerClient, err := dockerutils.New()
	if err != nil {
		return err
	}

	ctx := context.Background()

	filterArgs := filters.NewArgs()

	if len(rawLabels) > 0 {
		for i := range rawLabels {
			filterArgs.Add("label", rawLabels[i])
		}
	}

	if len(names) > 0 {
		for i := range names {
			filterArgs.Add("name", names[i])
		}
	}

	containers, err := dockerClient.ContainerList(ctx, types.ContainerListOptions{
		All:     allContainers,
		Filters: filterArgs,
	})
	if err != nil {
		return err
	}

	if len(ids) > 0 {
		containers = filterByIDs(containers, ids...)
	}

	for i := range containers {
		rc, err := dockerClient.ContainerLogs(ctx, containers[i].ID, types.ContainerLogsOptions{ShowStderr: true, ShowStdout: true})
		if err != nil {
			return err
		}
		defer rc.Close()

		_, err = io.Copy(os.Stdout, rc)
		if err != nil {
			return err
		}
	}
	return nil
}

func filterByIDs(containers []types.Container, ids ...string) []types.Container {
	cachedContainers := make([]types.Container, 0)
LOOP:
	for i := range containers {
		for j := range ids {
			if strings.HasPrefix(containers[i].ID, ids[j]) {
				cachedContainers = append(cachedContainers, containers[i])
				continue LOOP
			}
		}
	}
	return cachedContainers
}
