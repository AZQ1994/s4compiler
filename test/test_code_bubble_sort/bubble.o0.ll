; ModuleID = 'test/test_code_bubble_sort/bubble.c'
source_filename = "test/test_code_bubble_sort/bubble.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@N = global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4
@len = global i32 20, align 4

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc13, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* @len, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end14

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* @len, align 4
  %sub = sub nsw i32 %2, 1
  store i32 %sub, i32* %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %3 = load i32, i32* %j, align 4
  %4 = load i32, i32* %i, align 4
  %cmp2 = icmp sgt i32 %3, %4
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %5 = load i32, i32* %j, align 4
  %arrayidx = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %5
  %6 = load i32, i32* %arrayidx, align 4
  %7 = load i32, i32* %j, align 4
  %sub4 = sub nsw i32 %7, 1
  %arrayidx5 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4
  %8 = load i32, i32* %arrayidx5, align 4
  %cmp6 = icmp slt i32 %6, %8
  br i1 %cmp6, label %if.then, label %if.end

if.then:                                          ; preds = %for.body3
  %9 = load i32, i32* %j, align 4
  %arrayidx7 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %9
  %10 = load i32, i32* %arrayidx7, align 4
  store i32 %10, i32* %temp, align 4
  %11 = load i32, i32* %j, align 4
  %sub8 = sub nsw i32 %11, 1
  %arrayidx9 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub8
  %12 = load i32, i32* %arrayidx9, align 4
  %13 = load i32, i32* %j, align 4
  %arrayidx10 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %13
  store i32 %12, i32* %arrayidx10, align 4
  %14 = load i32, i32* %temp, align 4
  %15 = load i32, i32* %j, align 4
  %sub11 = sub nsw i32 %15, 1
  %arrayidx12 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub11
  store i32 %14, i32* %arrayidx12, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body3
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %16 = load i32, i32* %j, align 4
  %dec = add nsw i32 %16, -1
  store i32 %dec, i32* %j, align 4
  br label %for.cond1

for.end:                                          ; preds = %for.cond1
  br label %for.inc13

for.inc13:                                        ; preds = %for.end
  %17 = load i32, i32* %i, align 4
  %inc = add nsw i32 %17, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end14:                                        ; preds = %for.cond
  ret i32 0
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
