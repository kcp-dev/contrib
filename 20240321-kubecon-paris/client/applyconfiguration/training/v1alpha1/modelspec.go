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

// Code generated by applyconfiguration-gen. DO NOT EDIT.

package v1alpha1

// ModelSpecApplyConfiguration represents an declarative configuration of the ModelSpec type for use
// with apply.
type ModelSpecApplyConfiguration struct {
	Model         *string `json:"model,omitempty"`
	NProcPerNod   *int    `json:"nProcPerNod,omitempty"`
	Script        *string `json:"script,omitempty"`
	CkptDir       *string `json:"ckptDir,omitempty"`
	TokenizerPath *string `json:"tokenizerPath,omitempty"`
	MaxSeqLen     *string `json:"maxSeqLen,omitempty"`
	MaxBatchSize  *string `json:"maxBatchSize,omitempty"`
}

// ModelSpecApplyConfiguration constructs an declarative configuration of the ModelSpec type for use with
// apply.
func ModelSpec() *ModelSpecApplyConfiguration {
	return &ModelSpecApplyConfiguration{}
}

// WithModel sets the Model field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the Model field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithModel(value string) *ModelSpecApplyConfiguration {
	b.Model = &value
	return b
}

// WithNProcPerNod sets the NProcPerNod field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the NProcPerNod field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithNProcPerNod(value int) *ModelSpecApplyConfiguration {
	b.NProcPerNod = &value
	return b
}

// WithScript sets the Script field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the Script field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithScript(value string) *ModelSpecApplyConfiguration {
	b.Script = &value
	return b
}

// WithCkptDir sets the CkptDir field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the CkptDir field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithCkptDir(value string) *ModelSpecApplyConfiguration {
	b.CkptDir = &value
	return b
}

// WithTokenizerPath sets the TokenizerPath field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the TokenizerPath field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithTokenizerPath(value string) *ModelSpecApplyConfiguration {
	b.TokenizerPath = &value
	return b
}

// WithMaxSeqLen sets the MaxSeqLen field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the MaxSeqLen field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithMaxSeqLen(value string) *ModelSpecApplyConfiguration {
	b.MaxSeqLen = &value
	return b
}

// WithMaxBatchSize sets the MaxBatchSize field in the declarative configuration to the given value
// and returns the receiver, so that objects can be built by chaining "With" function invocations.
// If called multiple times, the MaxBatchSize field is set to the value of the last call.
func (b *ModelSpecApplyConfiguration) WithMaxBatchSize(value string) *ModelSpecApplyConfiguration {
	b.MaxBatchSize = &value
	return b
}
