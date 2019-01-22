; ModuleID = 'lev.c'
source_filename = "lev.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [128 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63, i32 64, i32 65, i32 66, i32 67, i32 68, i32 69, i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79, i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89, i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99, i32 100, i32 101, i32 102, i32 103, i32 104, i32 105, i32 106, i32 107, i32 108, i32 109, i32 110, i32 111, i32 112, i32 113, i32 114, i32 115, i32 116, i32 117, i32 118, i32 119, i32 120, i32 121, i32 122, i32 123, i32 124, i32 125, i32 126, i32 127], align 4
@main.str2 = private unnamed_addr constant [128 x i32] [i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0], align 4

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %.pre = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 0), align 4, !tbaa !1
  %.promoted = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 4), align 4, !tbaa !1
  %.promoted163 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 7), align 4, !tbaa !1
  br label %if.then32

if.then32:                                        ; preds = %if.end59.7, %entry
  %0 = phi i32 [ %.promoted163, %entry ], [ %left.1.7, %if.end59.7 ]
  %1 = phi i32 [ %.promoted, %entry ], [ %add38.4, %if.end59.7 ]
  %2 = phi i32 [ %.pre, %entry ], [ %add38.add, %if.end59.7 ]
  %j.0121 = phi i32 [ 0, %entry ], [ %add, %if.end59.7 ]
  %add = add nuw nsw i32 %j.0121, 1
  %arrayidx2 = getelementptr inbounds [128 x i32], [128 x i32]* @main.str2, i32 0, i32 %j.0121
  %3 = load i32, i32* %arrayidx2, align 4, !tbaa !1
  %cmp34 = icmp slt i32 %2, %j.0121
  %add38 = add nsw i32 %2, 1
  %add38.add = select i1 %cmp34, i32 %add38, i32 %add
  %cmp3.1 = icmp eq i32 %3, 105
  %cmp4.1 = icmp sle i32 %2, %add38.add
  %4 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 1), align 4, !tbaa !1
  br i1 %cmp3.1, label %if.then.1, label %if.else30.1

while.end:                                        ; preds = %if.end59.7
  store i32 %add38.add, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 0), align 4, !tbaa !1
  store i32 %add38.4, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 4), align 4, !tbaa !1
  store i32 %left.1.7, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 7), align 4, !tbaa !1
  ret i32 0

if.else30.1:                                      ; preds = %if.then32
  %add38.add.sink173 = select i1 %cmp4.1, i32 %2, i32 %add38.add
  %cmp47.1 = icmp slt i32 %4, %add38.add.sink173
  %.add38.add = select i1 %cmp47.1, i32 %4, i32 %add38.add.sink173
  %add38.1 = add nsw i32 %.add38.add, 1
  store i32 %add38.1, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 1), align 4, !tbaa !1
  %cmp3.2 = icmp eq i32 %3, 116
  %cmp4.2 = icmp sle i32 %4, %add38.1
  %5 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  br i1 %cmp3.2, label %if.then.2, label %if.else30.2

if.then.1:                                        ; preds = %if.then32
  br i1 %cmp4.1, label %if.then5.1, label %if.else16.1

if.else16.1:                                      ; preds = %if.then.1
  %cmp18.1 = icmp slt i32 %4, %add38.add
  br i1 %cmp18.1, label %if.then19.1, label %if.else24.1

if.else24.1:                                      ; preds = %if.else16.1
  %add25.1 = add nsw i32 %add38.add, 1
  br label %if.end59.1.thread

if.then19.1:                                      ; preds = %if.else16.1
  %add21.1 = add nsw i32 %4, 1
  br label %if.end59.1.thread

if.then5.1:                                       ; preds = %if.then.1
  %add7.1 = add nsw i32 %4, 1
  %cmp8.1 = icmp slt i32 %add7.1, %2
  %add7.left_top.0.1 = select i1 %cmp8.1, i32 %add7.1, i32 %2
  br label %if.end59.1.thread

if.end59.1.thread:                                ; preds = %if.then5.1, %if.then19.1, %if.else24.1
  %left.1.1.ph = phi i32 [ %add7.left_top.0.1, %if.then5.1 ], [ %add25.1, %if.else24.1 ], [ %add21.1, %if.then19.1 ]
  store i32 %left.1.1.ph, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 1), align 4, !tbaa !1
  %cmp4.2123 = icmp sgt i32 %4, %left.1.1.ph
  %6 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  br i1 %cmp4.2123, label %if.else45.2, label %if.then32.2

if.else30.2:                                      ; preds = %if.else30.1
  br i1 %cmp4.2, label %if.then32.2, label %if.else45.2

if.else45.2:                                      ; preds = %if.end59.1.thread, %if.else30.2
  %left.1.1124130 = phi i32 [ %left.1.1.ph, %if.end59.1.thread ], [ %add38.1, %if.else30.2 ]
  %7 = phi i32 [ %6, %if.end59.1.thread ], [ %5, %if.else30.2 ]
  %cmp47.2 = icmp slt i32 %7, %left.1.1124130
  br i1 %cmp47.2, label %if.then32.3.sink.split, label %if.end59.2

if.then32.2:                                      ; preds = %if.end59.1.thread, %if.else30.2
  %8 = phi i32 [ %6, %if.end59.1.thread ], [ %5, %if.else30.2 ]
  %cmp34.2 = icmp slt i32 %8, %4
  br i1 %cmp34.2, label %if.then32.3.sink.split, label %if.else40.2

if.else40.2:                                      ; preds = %if.then32.2
  %add41.2 = add nsw i32 %4, 1
  store i32 %add41.2, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  %cmp4.3136 = icmp sle i32 %8, %add41.2
  br label %if.else30.3

if.then.2:                                        ; preds = %if.else30.1
  br i1 %cmp4.2, label %if.then5.2, label %if.else16.2

if.else16.2:                                      ; preds = %if.then.2
  %cmp18.2 = icmp sgt i32 %5, %.add38.add
  br i1 %cmp18.2, label %if.else24.2, label %if.then19.2

if.else24.2:                                      ; preds = %if.else16.2
  %add25.2 = add nsw i32 %.add38.add, 2
  br label %if.end59.2.thread

if.then19.2:                                      ; preds = %if.else16.2
  %add21.2 = add nsw i32 %5, 1
  br label %if.end59.2.thread

if.then5.2:                                       ; preds = %if.then.2
  %add7.2 = add nsw i32 %5, 1
  %cmp8.2 = icmp slt i32 %add7.2, %4
  %add7.left_top.0.2 = select i1 %cmp8.2, i32 %add7.2, i32 %4
  br label %if.end59.2.thread

if.end59.2.thread:                                ; preds = %if.then19.2, %if.else24.2, %if.then5.2
  %left.1.2.ph = phi i32 [ %add7.left_top.0.2, %if.then5.2 ], [ %add25.2, %if.else24.2 ], [ %add21.2, %if.then19.2 ]
  store i32 %left.1.2.ph, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  %cmp4.3131 = icmp sgt i32 %5, %left.1.2.ph
  %9 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 3), align 4, !tbaa !1
  br i1 %cmp4.3131, label %if.else16.3, label %if.then5.3

if.end59.2:                                       ; preds = %if.else45.2
  %add54.2 = add nsw i32 %left.1.1124130, 1
  store i32 %add54.2, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  %cmp4.3 = icmp sle i32 %7, %add54.2
  br label %if.else30.3

if.else30.3:                                      ; preds = %if.else40.2, %if.end59.2
  %cmp4.3135 = phi i1 [ %cmp4.3, %if.end59.2 ], [ %cmp4.3136, %if.else40.2 ]
  %left.1.2134 = phi i32 [ %add54.2, %if.end59.2 ], [ %add41.2, %if.else40.2 ]
  %10 = phi i32 [ %7, %if.end59.2 ], [ %8, %if.else40.2 ]
  %11 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 3), align 4, !tbaa !1
  br i1 %cmp4.3135, label %if.then32.3, label %if.else45.3

if.else45.3:                                      ; preds = %if.else30.3
  %cmp47.3 = icmp slt i32 %11, %left.1.2134
  br i1 %cmp47.3, label %if.else30.4.thread, label %if.else53.3

if.else53.3:                                      ; preds = %if.else45.3
  %add54.3 = add nsw i32 %left.1.2134, 1
  br label %if.else30.4

if.then32.3.sink.split:                           ; preds = %if.else45.2, %if.then32.2
  %.sink165 = phi i32 [ %8, %if.then32.2 ], [ %7, %if.else45.2 ]
  %add38.2 = add nsw i32 %.sink165, 1
  store i32 %add38.2, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 2), align 4, !tbaa !1
  %12 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 3), align 4, !tbaa !1
  br label %if.then32.3

if.then32.3:                                      ; preds = %if.then32.3.sink.split, %if.else30.3
  %13 = phi i32 [ %10, %if.else30.3 ], [ %.sink165, %if.then32.3.sink.split ]
  %14 = phi i32 [ %11, %if.else30.3 ], [ %12, %if.then32.3.sink.split ]
  %cmp34.3 = icmp slt i32 %14, %13
  br i1 %cmp34.3, label %if.else30.4.thread, label %if.else40.3

if.else40.3:                                      ; preds = %if.then32.3
  %add41.3 = add nsw i32 %13, 1
  br label %if.else30.4

if.else16.3:                                      ; preds = %if.end59.2.thread
  %cmp18.3 = icmp slt i32 %9, %left.1.2.ph
  br i1 %cmp18.3, label %if.else30.4.thread, label %if.else24.3

if.else24.3:                                      ; preds = %if.else16.3
  %add25.3 = add nsw i32 %left.1.2.ph, 1
  br label %if.else30.4

if.then5.3:                                       ; preds = %if.end59.2.thread
  %add7.3 = add nsw i32 %9, 1
  %cmp8.3 = icmp slt i32 %add7.3, %5
  %add7.left_top.0.3 = select i1 %cmp8.3, i32 %add7.3, i32 %5
  br label %if.else30.4

if.else30.4.thread:                               ; preds = %if.else45.3, %if.else16.3, %if.then32.3
  %.sink166 = phi i32 [ %14, %if.then32.3 ], [ %9, %if.else16.3 ], [ %11, %if.else45.3 ]
  %add21.3 = add nsw i32 %.sink166, 1
  store i32 %add21.3, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 3), align 4, !tbaa !1
  br label %if.end59.4

if.else30.4:                                      ; preds = %if.else53.3, %if.else40.3, %if.else24.3, %if.then5.3
  %15 = phi i32 [ %9, %if.else24.3 ], [ %14, %if.else40.3 ], [ %11, %if.else53.3 ], [ %9, %if.then5.3 ]
  %left.1.3 = phi i32 [ %add25.3, %if.else24.3 ], [ %add41.3, %if.else40.3 ], [ %add54.3, %if.else53.3 ], [ %add7.left_top.0.3, %if.then5.3 ]
  store i32 %left.1.3, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 3), align 4, !tbaa !1
  %cmp4.4 = icmp sgt i32 %15, %left.1.3
  %left.1.3. = select i1 %cmp4.4, i32 %left.1.3, i32 %15
  br label %if.end59.4

if.end59.4:                                       ; preds = %if.else30.4, %if.else30.4.thread
  %left.1.3.sink175 = phi i32 [ %.sink166, %if.else30.4.thread ], [ %left.1.3., %if.else30.4 ]
  %cmp47.4 = icmp slt i32 %1, %left.1.3.sink175
  %.left.1.3 = select i1 %cmp47.4, i32 %1, i32 %left.1.3.sink175
  %add38.4 = add nsw i32 %.left.1.3, 1
  %cmp3.5 = icmp eq i32 %3, 110
  %cmp4.5 = icmp sle i32 %1, %add38.4
  %16 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 5), align 4, !tbaa !1
  br i1 %cmp3.5, label %if.then.5, label %if.else30.5

if.else30.5:                                      ; preds = %if.end59.4
  %add38.4.sink174 = select i1 %cmp4.5, i32 %1, i32 %add38.4
  %cmp47.5 = icmp slt i32 %16, %add38.4.sink174
  %.add38.4 = select i1 %cmp47.5, i32 %16, i32 %add38.4.sink174
  %add38.5 = add nsw i32 %.add38.4, 1
  store i32 %add38.5, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 5), align 4, !tbaa !1
  %cmp3.6 = icmp eq i32 %3, 0
  %cmp4.6 = icmp sle i32 %16, %add38.5
  %17 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  br i1 %cmp3.6, label %if.then.6, label %if.else30.6

if.then.5:                                        ; preds = %if.end59.4
  br i1 %cmp4.5, label %if.then5.5, label %if.else16.5

if.else16.5:                                      ; preds = %if.then.5
  %cmp18.5 = icmp sgt i32 %16, %.left.1.3
  br i1 %cmp18.5, label %if.else24.5, label %if.then19.5

if.else24.5:                                      ; preds = %if.else16.5
  %add25.5 = add nsw i32 %.left.1.3, 2
  br label %if.end59.5.thread

if.then19.5:                                      ; preds = %if.else16.5
  %add21.5 = add nsw i32 %16, 1
  br label %if.end59.5.thread

if.then5.5:                                       ; preds = %if.then.5
  %add7.5 = add nsw i32 %16, 1
  %cmp8.5 = icmp slt i32 %add7.5, %1
  %add7.left_top.0.5 = select i1 %cmp8.5, i32 %add7.5, i32 %1
  br label %if.end59.5.thread

if.end59.5.thread:                                ; preds = %if.then5.5, %if.then19.5, %if.else24.5
  %left.1.5.ph = phi i32 [ %add7.left_top.0.5, %if.then5.5 ], [ %add25.5, %if.else24.5 ], [ %add21.5, %if.then19.5 ]
  store i32 %left.1.5.ph, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 5), align 4, !tbaa !1
  %cmp4.6144 = icmp sgt i32 %16, %left.1.5.ph
  %18 = load i32, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  br i1 %cmp4.6144, label %if.else45.6, label %if.then32.6

if.else30.6:                                      ; preds = %if.else30.5
  br i1 %cmp4.6, label %if.then32.6, label %if.else45.6

if.else45.6:                                      ; preds = %if.end59.5.thread, %if.else30.6
  %left.1.5145151 = phi i32 [ %left.1.5.ph, %if.end59.5.thread ], [ %add38.5, %if.else30.6 ]
  %19 = phi i32 [ %18, %if.end59.5.thread ], [ %17, %if.else30.6 ]
  %cmp47.6 = icmp slt i32 %19, %left.1.5145151
  br i1 %cmp47.6, label %if.then32.7.sink.split, label %if.end59.6

if.then32.6:                                      ; preds = %if.end59.5.thread, %if.else30.6
  %20 = phi i32 [ %18, %if.end59.5.thread ], [ %17, %if.else30.6 ]
  %cmp34.6 = icmp slt i32 %20, %16
  br i1 %cmp34.6, label %if.then32.7.sink.split, label %if.else40.6

if.else40.6:                                      ; preds = %if.then32.6
  %add41.6 = add nsw i32 %16, 1
  store i32 %add41.6, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  %cmp4.7157 = icmp sle i32 %20, %add41.6
  br label %if.else30.7

if.then.6:                                        ; preds = %if.else30.5
  br i1 %cmp4.6, label %if.then5.6, label %if.else16.6

if.else16.6:                                      ; preds = %if.then.6
  %cmp18.6 = icmp sgt i32 %17, %.add38.4
  br i1 %cmp18.6, label %if.else24.6, label %if.then19.6

if.else24.6:                                      ; preds = %if.else16.6
  %add25.6 = add nsw i32 %.add38.4, 2
  br label %if.end59.6.thread

if.then19.6:                                      ; preds = %if.else16.6
  %add21.6 = add nsw i32 %17, 1
  br label %if.end59.6.thread

if.then5.6:                                       ; preds = %if.then.6
  %add7.6 = add nsw i32 %17, 1
  %cmp8.6 = icmp slt i32 %add7.6, %16
  %add7.left_top.0.6 = select i1 %cmp8.6, i32 %add7.6, i32 %16
  br label %if.end59.6.thread

if.end59.6.thread:                                ; preds = %if.then19.6, %if.else24.6, %if.then5.6
  %left.1.6.ph = phi i32 [ %add7.left_top.0.6, %if.then5.6 ], [ %add25.6, %if.else24.6 ], [ %add21.6, %if.then19.6 ]
  store i32 %left.1.6.ph, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  %cmp4.7152 = icmp sgt i32 %17, %left.1.6.ph
  br i1 %cmp4.7152, label %if.else16.7, label %if.then5.7

if.end59.6:                                       ; preds = %if.else45.6
  %add54.6 = add nsw i32 %left.1.5145151, 1
  store i32 %add54.6, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  %cmp4.7 = icmp sle i32 %19, %add54.6
  br label %if.else30.7

if.else30.7:                                      ; preds = %if.else40.6, %if.end59.6
  %cmp4.7156 = phi i1 [ %cmp4.7, %if.end59.6 ], [ %cmp4.7157, %if.else40.6 ]
  %left.1.6155 = phi i32 [ %add54.6, %if.end59.6 ], [ %add41.6, %if.else40.6 ]
  %21 = phi i32 [ %19, %if.end59.6 ], [ %20, %if.else40.6 ]
  br i1 %cmp4.7156, label %if.then32.7, label %if.else45.7

if.else45.7:                                      ; preds = %if.else30.7
  %cmp47.7 = icmp slt i32 %0, %left.1.6155
  br i1 %cmp47.7, label %if.then48.7, label %if.else53.7

if.else53.7:                                      ; preds = %if.else45.7
  %add54.7 = add nsw i32 %left.1.6155, 1
  br label %if.end59.7

if.then48.7:                                      ; preds = %if.else45.7
  %add50.7 = add nsw i32 %0, 1
  br label %if.end59.7

if.then32.7.sink.split:                           ; preds = %if.else45.6, %if.then32.6
  %.sink172 = phi i32 [ %20, %if.then32.6 ], [ %19, %if.else45.6 ]
  %add38.6 = add nsw i32 %.sink172, 1
  store i32 %add38.6, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @data, i32 0, i32 6), align 4, !tbaa !1
  br label %if.then32.7

if.then32.7:                                      ; preds = %if.then32.7.sink.split, %if.else30.7
  %22 = phi i32 [ %21, %if.else30.7 ], [ %.sink172, %if.then32.7.sink.split ]
  %cmp34.7 = icmp slt i32 %0, %22
  br i1 %cmp34.7, label %if.then35.7, label %if.else40.7

if.else40.7:                                      ; preds = %if.then32.7
  %add41.7 = add nsw i32 %22, 1
  br label %if.end59.7

if.then35.7:                                      ; preds = %if.then32.7
  %add38.7 = add nsw i32 %0, 1
  br label %if.end59.7

if.else16.7:                                      ; preds = %if.end59.6.thread
  %cmp18.7 = icmp slt i32 %0, %left.1.6.ph
  br i1 %cmp18.7, label %if.then19.7, label %if.else24.7

if.else24.7:                                      ; preds = %if.else16.7
  %add25.7 = add nsw i32 %left.1.6.ph, 1
  br label %if.end59.7

if.then19.7:                                      ; preds = %if.else16.7
  %add21.7 = add nsw i32 %0, 1
  br label %if.end59.7

if.then5.7:                                       ; preds = %if.end59.6.thread
  %add7.7 = add nsw i32 %0, 1
  %cmp8.7 = icmp slt i32 %add7.7, %17
  %add7.left_top.0.7 = select i1 %cmp8.7, i32 %add7.7, i32 %17
  br label %if.end59.7

if.end59.7:                                       ; preds = %if.then5.7, %if.then19.7, %if.else24.7, %if.then35.7, %if.else40.7, %if.then48.7, %if.else53.7
  %left.1.7 = phi i32 [ %add21.7, %if.then19.7 ], [ %add25.7, %if.else24.7 ], [ %add38.7, %if.then35.7 ], [ %add41.7, %if.else40.7 ], [ %add50.7, %if.then48.7 ], [ %add54.7, %if.else53.7 ], [ %add7.left_top.0.7, %if.then5.7 ]
  %exitcond = icmp eq i32 %add, 8
  br i1 %exitcond, label %while.end, label %if.then32
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
