; ModuleID = 'mips-quick-test.o0.ll'
source_filename = "mips-quick-test.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4

; Function Attrs: noinline nounwind
define i32 @quick(i32 %left, i32 %right) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %left
  %0 = load i32, i32* %arrayidx, align 4
  %cmp = icmp slt i32 %left, %right
  br i1 %cmp, label %for.cond.outer.preheader, label %return

for.cond.outer.preheader:                         ; preds = %entry
  br label %for.cond.outer

for.cond.outer:                                   ; preds = %for.cond.outer.preheader, %if.then4
  %1 = phi i32 [ %2, %if.then4 ], [ %0, %for.cond.outer.preheader ]
  %i.0.in.ph = phi i32 [ %i.0, %if.then4 ], [ %left, %for.cond.outer.preheader ]
  %last.0.ph = phi i32 [ %inc, %if.then4 ], [ %left, %for.cond.outer.preheader ]
  br label %for.cond

for.cond:                                         ; preds = %for.cond.outer, %for.body
  %i.0.in = phi i32 [ %i.0, %for.body ], [ %i.0.in.ph, %for.cond.outer ]
  %i.0 = add nsw i32 %i.0.in, 1
  %cmp1 = icmp slt i32 %i.0.in, %right
  br i1 %cmp1, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx2 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %i.0
  %2 = load i32, i32* %arrayidx2, align 4
  %cmp3 = icmp slt i32 %2, %0
  br i1 %cmp3, label %if.then4, label %for.cond

if.then4:                                         ; preds = %for.body
  %inc = add nsw i32 %last.0.ph, 1
  %arrayidx6 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %inc
  %3 = load i32, i32* %arrayidx6, align 4
  store i32 %3, i32* %arrayidx2, align 4
  store i32 %2, i32* %arrayidx6, align 4
  br label %for.cond.outer

for.end:                                          ; preds = %for.cond
  %4 = load i32, i32* %arrayidx, align 4
  %arrayidx12 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %last.0.ph
  store i32 %1, i32* %arrayidx, align 4
  store i32 %4, i32* %arrayidx12, align 4
  %sub = add nsw i32 %last.0.ph, -1
  %call = call i32 @quick(i32 %left, i32 %sub)
  %add15 = add nsw i32 %last.0.ph, 1
  %call16 = call i32 @quick(i32 %add15, i32 %right)
  br label %return

return:                                           ; preds = %entry, %for.end
  ret i32 0
}

; Function Attrs: noinline nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %call = call i32 @quick(i32 0, i32 19)
  ret i32 0
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}