; ModuleID = 'fib.c'
source_filename = "fib.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind readnone uwtable
define i32 @fib(i32 %a) local_unnamed_addr #0 {
entry:
  %switch = icmp ult i32 %a, 2
  br i1 %switch, label %return, label %sw.default

sw.default:                                       ; preds = %entry
  %sub = add nsw i32 %a, -2
  %call = tail call i32 @fib(i32 %sub)
  %sub2 = add nsw i32 %a, -1
  %call3 = tail call i32 @fib(i32 %sub2)
  %add = add nsw i32 %call3, %call
  ret i32 %add

return:                                           ; preds = %entry
  ret i32 %a
}

; Function Attrs: nounwind readnone uwtable
define i32 @main() local_unnamed_addr #0 {
entry:
  %call = tail call i32 @fib(i32 10)
  ret i32 %call
}

attributes #0 = { nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
