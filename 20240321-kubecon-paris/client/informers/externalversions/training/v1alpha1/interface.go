//go:build !ignore_autogenerated
// +build !ignore_autogenerated

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

// Code generated by kcp code-generator. DO NOT EDIT.

package v1alpha1

import (
	"github.com/faroshq/kcp-ml-shop/client/informers/externalversions/internalinterfaces"
)

type ClusterInterface interface {
	// Models returns a ModelClusterInformer
	Models() ModelClusterInformer
}

type version struct {
	factory          internalinterfaces.SharedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
}

// New returns a new ClusterInterface.
func New(f internalinterfaces.SharedInformerFactory, tweakListOptions internalinterfaces.TweakListOptionsFunc) ClusterInterface {
	return &version{factory: f, tweakListOptions: tweakListOptions}
}

// Models returns a ModelClusterInformer
func (v *version) Models() ModelClusterInformer {
	return &modelClusterInformer{factory: v.factory, tweakListOptions: v.tweakListOptions}
}

type Interface interface {
	// Models returns a ModelInformer
	Models() ModelInformer
}

type scopedVersion struct {
	factory          internalinterfaces.SharedScopedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
	namespace        string
}

// New returns a new ClusterInterface.
func NewScoped(f internalinterfaces.SharedScopedInformerFactory, namespace string, tweakListOptions internalinterfaces.TweakListOptionsFunc) Interface {
	return &scopedVersion{factory: f, namespace: namespace, tweakListOptions: tweakListOptions}
}

// Models returns a ModelInformer
func (v *scopedVersion) Models() ModelInformer {
	return &modelScopedInformer{factory: v.factory, tweakListOptions: v.tweakListOptions}
}
