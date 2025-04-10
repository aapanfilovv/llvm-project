; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py UTC_ARGS: --version 5
; RUN: opt < %s -disable-output "-passes=print<da>" -aa-pipeline=basic-aa 2>&1 \
; RUN: | FileCheck %s

; Check that the testcase does not crash the compiler.
; See https://github.com/llvm/llvm-project/issues/51512 for details.

define void @foo() {
; CHECK-LABEL: 'foo'
; CHECK-NEXT:  Src: store i32 42, ptr %getelementptr, align 1 --> Dst: store i32 42, ptr %getelementptr, align 1
; CHECK-NEXT:    da analyze - consistent output [0 S]!
; CHECK-NEXT:  Src: store i32 42, ptr %getelementptr, align 1 --> Dst: store i32 0, ptr %getelementptr5, align 1
; CHECK-NEXT:    da analyze - output [0 *|<]!
; CHECK-NEXT:  Src: store i32 0, ptr %getelementptr5, align 1 --> Dst: store i32 0, ptr %getelementptr5, align 1
; CHECK-NEXT:    da analyze - none!
;
bb:
  %alloca = alloca [2 x [5 x i32]], align 1
  br label %outerloop.header

outerloop.header:                                              ; preds = %outerloop.latch, %bb
  %iv.outerloop = phi i32 [ 0, %bb ], [ %iv.outerloop.next, %outerloop.latch ]
  %trunc = trunc i32 %iv.outerloop to i16
  %add = add i16 %trunc, 3
  %getelementptr = getelementptr inbounds [2 x [5 x i32]], ptr %alloca, i16 0, i16 %trunc, i16 %add
  br label %innerloop

innerloop:                                              ; preds = %innerloop, %outerloop.header
  %iv.innerloop = phi i32 [ 0, %outerloop.header ], [ %iv.innerloop.next, %innerloop ]
  store i32 42, ptr %getelementptr, align 1
  %trunc4 = trunc i32 %iv.innerloop to i16
  %getelementptr5 = getelementptr inbounds [2 x [5 x i32]], ptr %alloca, i16 0, i16 %trunc4, i16 %add
  store i32 0, ptr %getelementptr5, align 1
  %iv.innerloop.next = add nuw nsw i32 %iv.innerloop, 1
  br i1 false, label %innerloop, label %outerloop.latch

outerloop.latch:                                              ; preds = %innerloop
  %iv.outerloop.next = add nuw nsw i32 %iv.outerloop, 1
  %icmp = icmp eq i32 %iv.outerloop, 0
  br i1 %icmp, label %outerloop.header, label %bb9

bb9:                                              ; preds = %outerloop.latch
  ret void
}
