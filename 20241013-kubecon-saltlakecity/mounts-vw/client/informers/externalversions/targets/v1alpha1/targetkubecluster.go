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
	"context"
	"time"

	kcpcache "github.com/kcp-dev/apimachinery/v2/pkg/cache"
	kcpinformers "github.com/kcp-dev/apimachinery/v2/third_party/informers"
	"github.com/kcp-dev/logicalcluster/v3"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/tools/cache"

	targetsv1alpha1 "github.com/kcp-dev/contrib/mounts-virtualworkspace/apis/targets/v1alpha1"
	scopedclientset "github.com/kcp-dev/contrib/mounts-virtualworkspace/client/clientset/versioned"
	clientset "github.com/kcp-dev/contrib/mounts-virtualworkspace/client/clientset/versioned/cluster"
	"github.com/kcp-dev/contrib/mounts-virtualworkspace/client/informers/externalversions/internalinterfaces"
	targetsv1alpha1listers "github.com/kcp-dev/contrib/mounts-virtualworkspace/client/listers/targets/v1alpha1"
)

// TargetKubeClusterClusterInformer provides access to a shared informer and lister for
// TargetKubeClusters.
type TargetKubeClusterClusterInformer interface {
	Cluster(logicalcluster.Name) TargetKubeClusterInformer
	Informer() kcpcache.ScopeableSharedIndexInformer
	Lister() targetsv1alpha1listers.TargetKubeClusterClusterLister
}

type targetKubeClusterClusterInformer struct {
	factory          internalinterfaces.SharedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
}

// NewTargetKubeClusterClusterInformer constructs a new informer for TargetKubeCluster type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewTargetKubeClusterClusterInformer(client clientset.ClusterInterface, resyncPeriod time.Duration, indexers cache.Indexers) kcpcache.ScopeableSharedIndexInformer {
	return NewFilteredTargetKubeClusterClusterInformer(client, resyncPeriod, indexers, nil)
}

// NewFilteredTargetKubeClusterClusterInformer constructs a new informer for TargetKubeCluster type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewFilteredTargetKubeClusterClusterInformer(client clientset.ClusterInterface, resyncPeriod time.Duration, indexers cache.Indexers, tweakListOptions internalinterfaces.TweakListOptionsFunc) kcpcache.ScopeableSharedIndexInformer {
	return kcpinformers.NewSharedIndexInformer(
		&cache.ListWatch{
			ListFunc: func(options metav1.ListOptions) (runtime.Object, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.TargetsV1alpha1().TargetKubeClusters().List(context.TODO(), options)
			},
			WatchFunc: func(options metav1.ListOptions) (watch.Interface, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.TargetsV1alpha1().TargetKubeClusters().Watch(context.TODO(), options)
			},
		},
		&targetsv1alpha1.TargetKubeCluster{},
		resyncPeriod,
		indexers,
	)
}

func (f *targetKubeClusterClusterInformer) defaultInformer(client clientset.ClusterInterface, resyncPeriod time.Duration) kcpcache.ScopeableSharedIndexInformer {
	return NewFilteredTargetKubeClusterClusterInformer(client, resyncPeriod, cache.Indexers{
		kcpcache.ClusterIndexName: kcpcache.ClusterIndexFunc,
	},
		f.tweakListOptions,
	)
}

func (f *targetKubeClusterClusterInformer) Informer() kcpcache.ScopeableSharedIndexInformer {
	return f.factory.InformerFor(&targetsv1alpha1.TargetKubeCluster{}, f.defaultInformer)
}

func (f *targetKubeClusterClusterInformer) Lister() targetsv1alpha1listers.TargetKubeClusterClusterLister {
	return targetsv1alpha1listers.NewTargetKubeClusterClusterLister(f.Informer().GetIndexer())
}

// TargetKubeClusterInformer provides access to a shared informer and lister for
// TargetKubeClusters.
type TargetKubeClusterInformer interface {
	Informer() cache.SharedIndexInformer
	Lister() targetsv1alpha1listers.TargetKubeClusterLister
}

func (f *targetKubeClusterClusterInformer) Cluster(clusterName logicalcluster.Name) TargetKubeClusterInformer {
	return &targetKubeClusterInformer{
		informer: f.Informer().Cluster(clusterName),
		lister:   f.Lister().Cluster(clusterName),
	}
}

type targetKubeClusterInformer struct {
	informer cache.SharedIndexInformer
	lister   targetsv1alpha1listers.TargetKubeClusterLister
}

func (f *targetKubeClusterInformer) Informer() cache.SharedIndexInformer {
	return f.informer
}

func (f *targetKubeClusterInformer) Lister() targetsv1alpha1listers.TargetKubeClusterLister {
	return f.lister
}

type targetKubeClusterScopedInformer struct {
	factory          internalinterfaces.SharedScopedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
}

func (f *targetKubeClusterScopedInformer) Informer() cache.SharedIndexInformer {
	return f.factory.InformerFor(&targetsv1alpha1.TargetKubeCluster{}, f.defaultInformer)
}

func (f *targetKubeClusterScopedInformer) Lister() targetsv1alpha1listers.TargetKubeClusterLister {
	return targetsv1alpha1listers.NewTargetKubeClusterLister(f.Informer().GetIndexer())
}

// NewTargetKubeClusterInformer constructs a new informer for TargetKubeCluster type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewTargetKubeClusterInformer(client scopedclientset.Interface, resyncPeriod time.Duration, indexers cache.Indexers) cache.SharedIndexInformer {
	return NewFilteredTargetKubeClusterInformer(client, resyncPeriod, indexers, nil)
}

// NewFilteredTargetKubeClusterInformer constructs a new informer for TargetKubeCluster type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewFilteredTargetKubeClusterInformer(client scopedclientset.Interface, resyncPeriod time.Duration, indexers cache.Indexers, tweakListOptions internalinterfaces.TweakListOptionsFunc) cache.SharedIndexInformer {
	return cache.NewSharedIndexInformer(
		&cache.ListWatch{
			ListFunc: func(options metav1.ListOptions) (runtime.Object, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.TargetsV1alpha1().TargetKubeClusters().List(context.TODO(), options)
			},
			WatchFunc: func(options metav1.ListOptions) (watch.Interface, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.TargetsV1alpha1().TargetKubeClusters().Watch(context.TODO(), options)
			},
		},
		&targetsv1alpha1.TargetKubeCluster{},
		resyncPeriod,
		indexers,
	)
}

func (f *targetKubeClusterScopedInformer) defaultInformer(client scopedclientset.Interface, resyncPeriod time.Duration) cache.SharedIndexInformer {
	return NewFilteredTargetKubeClusterInformer(client, resyncPeriod, cache.Indexers{}, f.tweakListOptions)
}
