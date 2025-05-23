/*
Copyright The KCP Authors.

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

// Code generated by client-gen. DO NOT EDIT.

package fake

import (
	"context"
	json "encoding/json"
	"fmt"

	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	labels "k8s.io/apimachinery/pkg/labels"
	types "k8s.io/apimachinery/pkg/types"
	watch "k8s.io/apimachinery/pkg/watch"
	testing "k8s.io/client-go/testing"

	v1alpha1 "github.com/kcp-dev/contrib/mounts-virtualworkspace/apis/mounts/v1alpha1"
	mountsv1alpha1 "github.com/kcp-dev/contrib/mounts-virtualworkspace/client/applyconfiguration/mounts/v1alpha1"
)

// FakeKubeClusters implements KubeClusterInterface
type FakeKubeClusters struct {
	Fake *FakeMountsV1alpha1
}

var kubeclustersResource = v1alpha1.SchemeGroupVersion.WithResource("kubeclusters")

var kubeclustersKind = v1alpha1.SchemeGroupVersion.WithKind("KubeCluster")

// Get takes name of the kubeCluster, and returns the corresponding kubeCluster object, and an error if there is any.
func (c *FakeKubeClusters) Get(ctx context.Context, name string, options v1.GetOptions) (result *v1alpha1.KubeCluster, err error) {
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootGetActionWithOptions(kubeclustersResource, name, options), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// List takes label and field selectors, and returns the list of KubeClusters that match those selectors.
func (c *FakeKubeClusters) List(ctx context.Context, opts v1.ListOptions) (result *v1alpha1.KubeClusterList, err error) {
	emptyResult := &v1alpha1.KubeClusterList{}
	obj, err := c.Fake.
		Invokes(testing.NewRootListActionWithOptions(kubeclustersResource, kubeclustersKind, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}

	label, _, _ := testing.ExtractFromListOptions(opts)
	if label == nil {
		label = labels.Everything()
	}
	list := &v1alpha1.KubeClusterList{ListMeta: obj.(*v1alpha1.KubeClusterList).ListMeta}
	for _, item := range obj.(*v1alpha1.KubeClusterList).Items {
		if label.Matches(labels.Set(item.Labels)) {
			list.Items = append(list.Items, item)
		}
	}
	return list, err
}

// Watch returns a watch.Interface that watches the requested kubeClusters.
func (c *FakeKubeClusters) Watch(ctx context.Context, opts v1.ListOptions) (watch.Interface, error) {
	return c.Fake.
		InvokesWatch(testing.NewRootWatchActionWithOptions(kubeclustersResource, opts))
}

// Create takes the representation of a kubeCluster and creates it.  Returns the server's representation of the kubeCluster, and an error, if there is any.
func (c *FakeKubeClusters) Create(ctx context.Context, kubeCluster *v1alpha1.KubeCluster, opts v1.CreateOptions) (result *v1alpha1.KubeCluster, err error) {
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootCreateActionWithOptions(kubeclustersResource, kubeCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// Update takes the representation of a kubeCluster and updates it. Returns the server's representation of the kubeCluster, and an error, if there is any.
func (c *FakeKubeClusters) Update(ctx context.Context, kubeCluster *v1alpha1.KubeCluster, opts v1.UpdateOptions) (result *v1alpha1.KubeCluster, err error) {
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootUpdateActionWithOptions(kubeclustersResource, kubeCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// UpdateStatus was generated because the type contains a Status member.
// Add a +genclient:noStatus comment above the type to avoid generating UpdateStatus().
func (c *FakeKubeClusters) UpdateStatus(ctx context.Context, kubeCluster *v1alpha1.KubeCluster, opts v1.UpdateOptions) (result *v1alpha1.KubeCluster, err error) {
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootUpdateSubresourceActionWithOptions(kubeclustersResource, "status", kubeCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// Delete takes name of the kubeCluster and deletes it. Returns an error if one occurs.
func (c *FakeKubeClusters) Delete(ctx context.Context, name string, opts v1.DeleteOptions) error {
	_, err := c.Fake.
		Invokes(testing.NewRootDeleteActionWithOptions(kubeclustersResource, name, opts), &v1alpha1.KubeCluster{})
	return err
}

// DeleteCollection deletes a collection of objects.
func (c *FakeKubeClusters) DeleteCollection(ctx context.Context, opts v1.DeleteOptions, listOpts v1.ListOptions) error {
	action := testing.NewRootDeleteCollectionActionWithOptions(kubeclustersResource, opts, listOpts)

	_, err := c.Fake.Invokes(action, &v1alpha1.KubeClusterList{})
	return err
}

// Patch applies the patch and returns the patched kubeCluster.
func (c *FakeKubeClusters) Patch(ctx context.Context, name string, pt types.PatchType, data []byte, opts v1.PatchOptions, subresources ...string) (result *v1alpha1.KubeCluster, err error) {
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(kubeclustersResource, name, pt, data, opts, subresources...), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// Apply takes the given apply declarative configuration, applies it and returns the applied kubeCluster.
func (c *FakeKubeClusters) Apply(ctx context.Context, kubeCluster *mountsv1alpha1.KubeClusterApplyConfiguration, opts v1.ApplyOptions) (result *v1alpha1.KubeCluster, err error) {
	if kubeCluster == nil {
		return nil, fmt.Errorf("kubeCluster provided to Apply must not be nil")
	}
	data, err := json.Marshal(kubeCluster)
	if err != nil {
		return nil, err
	}
	name := kubeCluster.Name
	if name == nil {
		return nil, fmt.Errorf("kubeCluster.Name must be provided to Apply")
	}
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(kubeclustersResource, *name, types.ApplyPatchType, data, opts.ToPatchOptions()), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}

// ApplyStatus was generated because the type contains a Status member.
// Add a +genclient:noStatus comment above the type to avoid generating ApplyStatus().
func (c *FakeKubeClusters) ApplyStatus(ctx context.Context, kubeCluster *mountsv1alpha1.KubeClusterApplyConfiguration, opts v1.ApplyOptions) (result *v1alpha1.KubeCluster, err error) {
	if kubeCluster == nil {
		return nil, fmt.Errorf("kubeCluster provided to Apply must not be nil")
	}
	data, err := json.Marshal(kubeCluster)
	if err != nil {
		return nil, err
	}
	name := kubeCluster.Name
	if name == nil {
		return nil, fmt.Errorf("kubeCluster.Name must be provided to Apply")
	}
	emptyResult := &v1alpha1.KubeCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(kubeclustersResource, *name, types.ApplyPatchType, data, opts.ToPatchOptions(), "status"), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.KubeCluster), err
}
