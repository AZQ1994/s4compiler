; ModuleID = 'test/test_code_quick/mips-quick-test.c'
source_filename = "test/test_code_quick/mips-quick-test.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4

; Function Attrs: noinline nounwind
define i32 @quick(i32 %left, i32 %right) #0 {
entry:
  %retval = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %pivot = alloca i32, align 4
  %i = alloca i32, align 4
  %temp = alloca i32, align 4
  %last = alloca i32, align 4
  store i32 %left, i32* %left.addr, align 4
  store i32 %right, i32* %right.addr, align 4
  %0 = load i32, i32* %left.addr, align 4
  %arrayidx = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %0
  %1 = load i32, i32* %arrayidx, align 4
  store i32 %1, i32* %pivot, align 4
  %2 = load i32, i32* %left.addr, align 4
  store i32 %2, i32* %last, align 4
  %3 = load i32, i32* %left.addr, align 4
  %4 = load i32, i32* %right.addr, align 4
  %sub = sub nsw i32 %3, %4
  %cmp = icmp sge i32 %sub, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %5 = load i32, i32* %left.addr, align 4
  %add = add nsw i32 %5, 1
  store i32 %add, i32* %i, align 4
  br label %while.cond

while.cond:                                       ; preds = %if.end11, %if.end
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %right.addr, align 4
  %sub1 = sub nsw i32 %6, %7
  %cmp2 = icmp sle i32 %sub1, 0
  br i1 %cmp2, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %8 = load i32, i32* %i, align 4
  %arrayidx3 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %8
  %9 = load i32, i32* %arrayidx3, align 4
  %10 = load i32, i32* %pivot, align 4
  %sub4 = sub nsw i32 %9, %10
  %cmp5 = icmp slt i32 %sub4, 0
  br i1 %cmp5, label %if.then6, label %if.end11

if.then6:                                         ; preds = %while.body
  %11 = load i32, i32* %last, align 4
  %inc = add nsw i32 %11, 1
  store i32 %inc, i32* %last, align 4
  %12 = load i32, i32* %i, align 4
  %arrayidx7 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %12
  %13 = load i32, i32* %arrayidx7, align 4
  store i32 %13, i32* %temp, align 4
  %14 = load i32, i32* %last, align 4
  %arrayidx8 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %14
  %15 = load i32, i32* %arrayidx8, align 4
  %16 = load i32, i32* %i, align 4
  %arrayidx9 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %16
  store i32 %15, i32* %arrayidx9, align 4
  %17 = load i32, i32* %temp, align 4
  %18 = load i32, i32* %last, align 4
  %arrayidx10 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %18
  store i32 %17, i32* %arrayidx10, align 4
  br label %if.end11

if.end11:                                         ; preds = %if.then6, %while.body
  %19 = load i32, i32* %i, align 4
  %inc12 = add nsw i32 %19, 1
  store i32 %inc12, i32* %i, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %20 = load i32, i32* %left.addr, align 4
  %arrayidx13 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %20
  %21 = load i32, i32* %arrayidx13, align 4
  store i32 %21, i32* %temp, align 4
  %22 = load i32, i32* %last, align 4
  %arrayidx14 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %22
  %23 = load i32, i32* %arrayidx14, align 4
  %24 = load i32, i32* %left.addr, align 4
  %arrayidx15 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %24
  store i32 %23, i32* %arrayidx15, align 4
  %25 = load i32, i32* %temp, align 4
  %26 = load i32, i32* %last, align 4
  %arrayidx16 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %26
  store i32 %25, i32* %arrayidx16, align 4
  %27 = load i32, i32* %left.addr, align 4
  %28 = load i32, i32* %last, align 4
  %sub17 = sub nsw i32 %28, 1
  %call = call i32 @quick(i32 %27, i32 %sub17)
  %29 = load i32, i32* %last, align 4
  %add18 = add nsw i32 %29, 1
  %30 = load i32, i32* %right.addr, align 4
  %call19 = call i32 @quick(i32 %add18, i32 %30)
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %while.end, %if.then
  %31 = load i32, i32* %retval, align 4
  ret i32 %31
}

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call i32 @quick(i32 0, i32 19)
  ret i32 0
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
