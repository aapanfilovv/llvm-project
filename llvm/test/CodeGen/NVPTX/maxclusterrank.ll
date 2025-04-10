; RUN: llc < %s -mtriple=nvptx64 -mcpu=sm_90 | FileCheck %s --check-prefixes=CHECK,CHECK_SM_90
; RUN: llc < %s -mtriple=nvptx64 -mcpu=sm_80 | FileCheck %s --check-prefixes=CHECK,CHECK_SM_80

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v32:32:32-v64:64:64-v128:128:128-n16:32:64"
target triple = "nvptx64-unknown-unknown"

; CHECK: .maxntid 128
; CHECK: .minnctapersm 2
; CHECK_SM_90: .maxclusterrank 8
; CHECK_SM_80-NOT: .maxclusterrank 8

; Make sure that for SM version prior to 90 `.maxclusterrank` directive is
; silently ignored.
define dso_local ptx_kernel void @_Z18TestMaxClusterRankv() "nvvm.minctasm"="2" "nvvm.maxclusterrank"="8" "nvvm.maxntid"="128" {
entry:
  %a = alloca i32, align 4
  store volatile i32 1, ptr %a, align 4
  ret void
}
