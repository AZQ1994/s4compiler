; ModuleID = 'lev.c'
source_filename = "lev.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = global [128 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63, i32 64, i32 65, i32 66, i32 67, i32 68, i32 69, i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79, i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89, i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99, i32 100, i32 101, i32 102, i32 103, i32 104, i32 105, i32 106, i32 107, i32 108, i32 109, i32 110, i32 111, i32 112, i32 113, i32 114, i32 115, i32 116, i32 117, i32 118, i32 119, i32 120, i32 121, i32 122, i32 123, i32 124, i32 125, i32 126, i32 127], align 4
@main.str1 = private unnamed_addr constant [128 x i32] [i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0], align 4
@main.str2 = private unnamed_addr constant [128 x i32] [i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0], align 4

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %size = alloca i32, align 4
  %str1 = alloca [128 x i32], align 4
  %str2 = alloca [128 x i32], align 4
  %left = alloca i32, align 4
  %left_top = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 8, i32* %size, align 4
  %0 = bitcast [128 x i32]* %str1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %0, i8* bitcast ([128 x i32]* @main.str1 to i8*), i32 512, i32 4, i1 false)
  %1 = bitcast [128 x i32]* %str2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %1, i8* bitcast ([128 x i32]* @main.str2 to i8*), i32 512, i32 4, i1 false)
  store i32 0, i32* %left, align 4
  store i32 0, i32* %left_top, align 4
  store i32 0, i32* %j, align 4
  br label %while.cond

while.cond:                                       ; preds = %for.end, %entry
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %size, align 4
  %cmp = icmp slt i32 %2, %3
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %4 = load i32, i32* %j, align 4
  store i32 %4, i32* %left_top, align 4
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %5, 1
  store i32 %add, i32* %left, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %while.body
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %size, align 4
  %cmp1 = icmp slt i32 %6, %7
  br i1 %cmp1, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %8 = load i32, i32* %i, align 4
  %arrayidx = getelementptr inbounds [128 x i32], [128 x i32]* %str1, i32 0, i32 %8
  %9 = load i32, i32* %arrayidx, align 4
  %10 = load i32, i32* %j, align 4
  %arrayidx2 = getelementptr inbounds [128 x i32], [128 x i32]* %str2, i32 0, i32 %10
  %11 = load i32, i32* %arrayidx2, align 4
  %cmp3 = icmp eq i32 %9, %11
  br i1 %cmp3, label %if.then, label %if.else30

if.then:                                          ; preds = %for.body
  %12 = load i32, i32* %left_top, align 4
  %13 = load i32, i32* %left, align 4
  %cmp4 = icmp sle i32 %12, %13
  br i1 %cmp4, label %if.then5, label %if.else16

if.then5:                                         ; preds = %if.then
  %14 = load i32, i32* %i, align 4
  %arrayidx6 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %14
  %15 = load i32, i32* %arrayidx6, align 4
  %add7 = add nsw i32 %15, 1
  %16 = load i32, i32* %left_top, align 4
  %cmp8 = icmp slt i32 %add7, %16
  br i1 %cmp8, label %if.then9, label %if.else

if.then9:                                         ; preds = %if.then5
  %17 = load i32, i32* %i, align 4
  %arrayidx10 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %17
  %18 = load i32, i32* %arrayidx10, align 4
  store i32 %18, i32* %left_top, align 4
  %19 = load i32, i32* %i, align 4
  %arrayidx11 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %19
  %20 = load i32, i32* %arrayidx11, align 4
  %add12 = add nsw i32 %20, 1
  store i32 %add12, i32* %left, align 4
  %21 = load i32, i32* %left, align 4
  %22 = load i32, i32* %i, align 4
  %arrayidx13 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %22
  store i32 %21, i32* %arrayidx13, align 4
  br label %if.end

if.else:                                          ; preds = %if.then5
  %23 = load i32, i32* %left_top, align 4
  store i32 %23, i32* %left, align 4
  %24 = load i32, i32* %i, align 4
  %arrayidx14 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %24
  %25 = load i32, i32* %arrayidx14, align 4
  store i32 %25, i32* %left_top, align 4
  %26 = load i32, i32* %left, align 4
  %27 = load i32, i32* %i, align 4
  %arrayidx15 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %27
  store i32 %26, i32* %arrayidx15, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then9
  br label %if.end29

if.else16:                                        ; preds = %if.then
  %28 = load i32, i32* %i, align 4
  %arrayidx17 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %28
  %29 = load i32, i32* %arrayidx17, align 4
  %30 = load i32, i32* %left, align 4
  %cmp18 = icmp slt i32 %29, %30
  br i1 %cmp18, label %if.then19, label %if.else24

if.then19:                                        ; preds = %if.else16
  %31 = load i32, i32* %i, align 4
  %arrayidx20 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %31
  %32 = load i32, i32* %arrayidx20, align 4
  %add21 = add nsw i32 %32, 1
  store i32 %add21, i32* %left, align 4
  %33 = load i32, i32* %i, align 4
  %arrayidx22 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %33
  %34 = load i32, i32* %arrayidx22, align 4
  store i32 %34, i32* %left_top, align 4
  %35 = load i32, i32* %left, align 4
  %36 = load i32, i32* %i, align 4
  %arrayidx23 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %36
  store i32 %35, i32* %arrayidx23, align 4
  br label %if.end28

if.else24:                                        ; preds = %if.else16
  %37 = load i32, i32* %left, align 4
  %add25 = add nsw i32 %37, 1
  store i32 %add25, i32* %left, align 4
  %38 = load i32, i32* %i, align 4
  %arrayidx26 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %38
  %39 = load i32, i32* %arrayidx26, align 4
  store i32 %39, i32* %left_top, align 4
  %40 = load i32, i32* %left, align 4
  %41 = load i32, i32* %i, align 4
  %arrayidx27 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %41
  store i32 %40, i32* %arrayidx27, align 4
  br label %if.end28

if.end28:                                         ; preds = %if.else24, %if.then19
  br label %if.end29

if.end29:                                         ; preds = %if.end28, %if.end
  br label %if.end59

if.else30:                                        ; preds = %for.body
  %42 = load i32, i32* %left_top, align 4
  %43 = load i32, i32* %left, align 4
  %cmp31 = icmp sle i32 %42, %43
  br i1 %cmp31, label %if.then32, label %if.else45

if.then32:                                        ; preds = %if.else30
  %44 = load i32, i32* %i, align 4
  %arrayidx33 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %44
  %45 = load i32, i32* %arrayidx33, align 4
  %46 = load i32, i32* %left_top, align 4
  %cmp34 = icmp slt i32 %45, %46
  br i1 %cmp34, label %if.then35, label %if.else40

if.then35:                                        ; preds = %if.then32
  %47 = load i32, i32* %i, align 4
  %arrayidx36 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %47
  %48 = load i32, i32* %arrayidx36, align 4
  store i32 %48, i32* %left_top, align 4
  %49 = load i32, i32* %i, align 4
  %arrayidx37 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %49
  %50 = load i32, i32* %arrayidx37, align 4
  %add38 = add nsw i32 %50, 1
  store i32 %add38, i32* %left, align 4
  %51 = load i32, i32* %left, align 4
  %52 = load i32, i32* %i, align 4
  %arrayidx39 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %52
  store i32 %51, i32* %arrayidx39, align 4
  br label %if.end44

if.else40:                                        ; preds = %if.then32
  %53 = load i32, i32* %left_top, align 4
  %add41 = add nsw i32 %53, 1
  store i32 %add41, i32* %left, align 4
  %54 = load i32, i32* %i, align 4
  %arrayidx42 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %54
  %55 = load i32, i32* %arrayidx42, align 4
  store i32 %55, i32* %left_top, align 4
  %56 = load i32, i32* %left, align 4
  %57 = load i32, i32* %i, align 4
  %arrayidx43 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %57
  store i32 %56, i32* %arrayidx43, align 4
  br label %if.end44

if.end44:                                         ; preds = %if.else40, %if.then35
  br label %if.end58

if.else45:                                        ; preds = %if.else30
  %58 = load i32, i32* %i, align 4
  %arrayidx46 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %58
  %59 = load i32, i32* %arrayidx46, align 4
  %60 = load i32, i32* %left, align 4
  %cmp47 = icmp slt i32 %59, %60
  br i1 %cmp47, label %if.then48, label %if.else53

if.then48:                                        ; preds = %if.else45
  %61 = load i32, i32* %i, align 4
  %arrayidx49 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %61
  %62 = load i32, i32* %arrayidx49, align 4
  %add50 = add nsw i32 %62, 1
  store i32 %add50, i32* %left, align 4
  %63 = load i32, i32* %i, align 4
  %arrayidx51 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %63
  %64 = load i32, i32* %arrayidx51, align 4
  store i32 %64, i32* %left_top, align 4
  %65 = load i32, i32* %left, align 4
  %66 = load i32, i32* %i, align 4
  %arrayidx52 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %66
  store i32 %65, i32* %arrayidx52, align 4
  br label %if.end57

if.else53:                                        ; preds = %if.else45
  %67 = load i32, i32* %left, align 4
  %add54 = add nsw i32 %67, 1
  store i32 %add54, i32* %left, align 4
  %68 = load i32, i32* %i, align 4
  %arrayidx55 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %68
  %69 = load i32, i32* %arrayidx55, align 4
  store i32 %69, i32* %left_top, align 4
  %70 = load i32, i32* %left, align 4
  %71 = load i32, i32* %i, align 4
  %arrayidx56 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %71
  store i32 %70, i32* %arrayidx56, align 4
  br label %if.end57

if.end57:                                         ; preds = %if.else53, %if.then48
  br label %if.end58

if.end58:                                         ; preds = %if.end57, %if.end44
  br label %if.end59

if.end59:                                         ; preds = %if.end58, %if.end29
  br label %for.inc

for.inc:                                          ; preds = %if.end59
  %72 = load i32, i32* %i, align 4
  %inc = add nsw i32 %72, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %73 = load i32, i32* %j, align 4
  %inc60 = add nsw i32 %73, 1
  store i32 %inc60, i32* %j, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  ret i32 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #1

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
