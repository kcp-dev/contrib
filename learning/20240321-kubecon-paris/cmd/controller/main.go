package main

import (
	goflag "flag"
	"fmt"
	"os"

	"github.com/faroshq/kcp-ml-shop/cmd/controller/command"
	"github.com/spf13/pflag"

	genericapiserver "k8s.io/apiserver/pkg/server"
)

func main() {
	ctx := genericapiserver.SetupSignalContext()

	pflag.CommandLine.AddGoFlagSet(goflag.CommandLine)

	command := command.NewCommand(ctx, os.Stderr)
	if err := command.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}
