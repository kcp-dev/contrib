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

	v1alpha1 "github.com/kcp-dev/contrib/mounts-virtualworkspace/apis/targets/v1alpha1"
	targetsv1alpha1 "github.com/kcp-dev/contrib/mounts-virtualworkspace/client/applyconfiguration/targets/v1alpha1"
)

// FakeTargetVClusters implements TargetVClusterInterface
type FakeTargetVClusters struct {
	Fake *FakeTargetsV1alpha1
}

var targetvclustersResource = v1alpha1.SchemeGroupVersion.WithResource("targetvclusters")

var targetvclustersKind = v1alpha1.SchemeGroupVersion.WithKind("TargetVCluster")

// Get takes name of the targetVCluster, and returns the corresponding targetVCluster object, and an error if there is any.
func (c *FakeTargetVClusters) Get(ctx context.Context, name string, options v1.GetOptions) (result *v1alpha1.TargetVCluster, err error) {
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootGetActionWithOptions(targetvclustersResource, name, options), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// List takes label and field selectors, and returns the list of TargetVClusters that match those selectors.
func (c *FakeTargetVClusters) List(ctx context.Context, opts v1.ListOptions) (result *v1alpha1.TargetVClusterList, err error) {
	emptyResult := &v1alpha1.TargetVClusterList{}
	obj, err := c.Fake.
		Invokes(testing.NewRootListActionWithOptions(targetvclustersResource, targetvclustersKind, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}

	label, _, _ := testing.ExtractFromListOptions(opts)
	if label == nil {
		label = labels.Everything()
	}
	list := &v1alpha1.TargetVClusterList{ListMeta: obj.(*v1alpha1.TargetVClusterList).ListMeta}
	for _, item := range obj.(*v1alpha1.TargetVClusterList).Items {
		if label.Matches(labels.Set(item.Labels)) {
			list.Items = append(list.Items, item)
		}
	}
	return list, err
}

// Watch returns a watch.Interface that watches the requested targetVClusters.
func (c *FakeTargetVClusters) Watch(ctx context.Context, opts v1.ListOptions) (watch.Interface, error) {
	return c.Fake.
		InvokesWatch(testing.NewRootWatchActionWithOptions(targetvclustersResource, opts))
}

// Create takes the representation of a targetVCluster and creates it.  Returns the server's representation of the targetVCluster, and an error, if there is any.
func (c *FakeTargetVClusters) Create(ctx context.Context, targetVCluster *v1alpha1.TargetVCluster, opts v1.CreateOptions) (result *v1alpha1.TargetVCluster, err error) {
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootCreateActionWithOptions(targetvclustersResource, targetVCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// Update takes the representation of a targetVCluster and updates it. Returns the server's representation of the targetVCluster, and an error, if there is any.
func (c *FakeTargetVClusters) Update(ctx context.Context, targetVCluster *v1alpha1.TargetVCluster, opts v1.UpdateOptions) (result *v1alpha1.TargetVCluster, err error) {
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootUpdateActionWithOptions(targetvclustersResource, targetVCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// UpdateStatus was generated because the type contains a Status member.
// Add a +genclient:noStatus comment above the type to avoid generating UpdateStatus().
func (c *FakeTargetVClusters) UpdateStatus(ctx context.Context, targetVCluster *v1alpha1.TargetVCluster, opts v1.UpdateOptions) (result *v1alpha1.TargetVCluster, err error) {
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootUpdateSubresourceActionWithOptions(targetvclustersResource, "status", targetVCluster, opts), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// Delete takes name of the targetVCluster and deletes it. Returns an error if one occurs.
func (c *FakeTargetVClusters) Delete(ctx context.Context, name string, opts v1.DeleteOptions) error {
	_, err := c.Fake.
		Invokes(testing.NewRootDeleteActionWithOptions(targetvclustersResource, name, opts), &v1alpha1.TargetVCluster{})
	return err
}

// DeleteCollection deletes a collection of objects.
func (c *FakeTargetVClusters) DeleteCollection(ctx context.Context, opts v1.DeleteOptions, listOpts v1.ListOptions) error {
	action := testing.NewRootDeleteCollectionActionWithOptions(targetvclustersResource, opts, listOpts)

	_, err := c.Fake.Invokes(action, &v1alpha1.TargetVClusterList{})
	return err
}

// Patch applies the patch and returns the patched targetVCluster.
func (c *FakeTargetVClusters) Patch(ctx context.Context, name string, pt types.PatchType, data []byte, opts v1.PatchOptions, subresources ...string) (result *v1alpha1.TargetVCluster, err error) {
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(targetvclustersResource, name, pt, data, opts, subresources...), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// Apply takes the given apply declarative configuration, applies it and returns the applied targetVCluster.
func (c *FakeTargetVClusters) Apply(ctx context.Context, targetVCluster *targetsv1alpha1.TargetVClusterApplyConfiguration, opts v1.ApplyOptions) (result *v1alpha1.TargetVCluster, err error) {
	if targetVCluster == nil {
		return nil, fmt.Errorf("targetVCluster provided to Apply must not be nil")
	}
	data, err := json.Marshal(targetVCluster)
	if err != nil {
		return nil, err
	}
	name := targetVCluster.Name
	if name == nil {
		return nil, fmt.Errorf("targetVCluster.Name must be provided to Apply")
	}
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(targetvclustersResource, *name, types.ApplyPatchType, data, opts.ToPatchOptions()), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}

// ApplyStatus was generated because the type contains a Status member.
// Add a +genclient:noStatus comment above the type to avoid generating ApplyStatus().
func (c *FakeTargetVClusters) ApplyStatus(ctx context.Context, targetVCluster *targetsv1alpha1.TargetVClusterApplyConfiguration, opts v1.ApplyOptions) (result *v1alpha1.TargetVCluster, err error) {
	if targetVCluster == nil {
		return nil, fmt.Errorf("targetVCluster provided to Apply must not be nil")
	}
	data, err := json.Marshal(targetVCluster)
	if err != nil {
		return nil, err
	}
	name := targetVCluster.Name
	if name == nil {
		return nil, fmt.Errorf("targetVCluster.Name must be provided to Apply")
	}
	emptyResult := &v1alpha1.TargetVCluster{}
	obj, err := c.Fake.
		Invokes(testing.NewRootPatchSubresourceActionWithOptions(targetvclustersResource, *name, types.ApplyPatchType, data, opts.ToPatchOptions(), "status"), emptyResult)
	if obj == nil {
		return emptyResult, err
	}
	return obj.(*v1alpha1.TargetVCluster), err
}
