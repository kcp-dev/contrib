/*
Copyright 2023 The KCP Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package resources

import (
	"context"
	"embed"
	"fmt"

	confighelpers "github.com/kcp-dev/kcp/config/helpers"
	kcpclientcluster "github.com/kcp-dev/kcp/sdk/client/clientset/versioned/cluster"
	"github.com/kcp-dev/logicalcluster/v3"

	"k8s.io/apimachinery/pkg/util/sets"
	"k8s.io/client-go/discovery"
	"k8s.io/client-go/dynamic"
)

//go:embed *.yaml
var KubeFS embed.FS

var clusterName = logicalcluster.NewPath("root:ml:training")

// Bootstrap creates resources in this package by continuously retrying the list.
// This is blocking, i.e. it only returns (with error) when the context is closed or with nil when
// the bootstrapping is successfully completed.
// TODO: comment bellow does not make sense, needs porting from tmc
// Note: Any change to the list of resources in the kubernetes apiexport has to be kept consistent with:
//   - pkg/reconciler/workload/apiexport/workload_apiexport_reconcile.go
func Bootstrap(ctx context.Context, kcpClient kcpclientcluster.ClusterInterface, discoveryClient discovery.DiscoveryInterface, dynamicClient dynamic.Interface, batteriesIncluded sets.Set[string]) error {
	//logger := klog.FromContext(ctx)

	err := confighelpers.Bootstrap(ctx, discoveryClient, dynamicClient, batteriesIncluded, KubeFS)
	if err != nil {
		return fmt.Errorf("error bootstrapping resources: %w", err)
	}

	return nil

}
