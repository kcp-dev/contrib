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

package v1alpha1

import (
	conditionsv1alpha1 "github.com/kcp-dev/kcp/sdk/apis/third_party/conditions/apis/conditions/v1alpha1"

	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Model describes a training job model
//
// +crd
// +genclient
// +genclient:nonNamespaced
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:subresource:status
// +kubebuilder:resource:scope=Cluster,categories=faros
type Model struct {
	v1.TypeMeta `json:",inline"`
	// +optional
	v1.ObjectMeta `json:"metadata,omitempty"`
	// +optional
	Spec ModelSpec `json:"spec,omitempty"`
	// +optional
	Status ModelStatus `json:"status,omitempty"`
}

// ModelSpec is the specification of the Model to be created
type ModelSpec struct {
	// +optional
	// +kubebuilder:validation:Enum=Llama2
	Model string `json:"model,omitempty"`
	// +optional
	NProcPerNod int `json:"nProcPerNod,omitempty"`
	// +optional
	Script string `json:"script,omitempty"`
	// +optional
	CkptDir string `json:"ckptDir,omitempty"`
	// +optional
	TokenizerPath string `json:"tokenizerPath,omitempty"`
	// +optional
	MaxSeqLen string `json:"maxSeqLen,omitempty"`
	// +optional
	MaxBatchSize string `json:"maxBatchSize,omitempty"`
}

// ModelStatus communicates the observed state of the model
type ModelStatus struct {
	// +kubebuilder:validation:Enum=Pending;Accepted;Running;Completed;Failed
	// +kubebuilder:default=Pending
	Phase ModelPhase `json:"state,omitempty"`

	// Location is the location of the model job
	// +optional
	Location string `json:"location,omitempty"`

	// Current processing state of the Cluster proxy.
	// +optional
	Conditions conditionsv1alpha1.Conditions `json:"conditions,omitempty"`
}

// ModelPhase is the states for Model job (Pending, Accepted, Running, Completed, Failed).
//
// +kubebuilder:validation:Enum=Pending;Accepted;Running;Completed;Failed
type ModelPhase string

const (
	// Pending means the model is pending
	ModelPhasePending ModelPhase = "Pending"
	// Accepted means the model is accepted
	ModelPhaseAccepted ModelPhase = "Accepted"
	// Running means the model is running
	ModelPhaseRunning ModelPhase = "Running"
	// Completed means the model is completed
	ModelPhaseCompleted ModelPhase = "Completed"
	// Failed means the model is failed
	ModelPhaseFailed ModelPhase = "Failed"
)

// ModelList is a list of Models resources
//
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
type ModelList struct {
	v1.TypeMeta `json:",inline"`
	v1.ListMeta `json:"metadata"`

	Items []Model `json:"items"`
}

func (in *Model) SetConditions(c conditionsv1alpha1.Conditions) {
	in.Status.Conditions = c
}

func (in *Model) GetConditions() conditionsv1alpha1.Conditions {
	return in.Status.Conditions
}
