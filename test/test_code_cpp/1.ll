; ModuleID = '1.cpp'
source_filename = "1.cpp"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

%class.Rectangle = type { i32, i32 }

@res = local_unnamed_addr global i32 0, align 4
@input1 = local_unnamed_addr global i32 3, align 4
@input2 = local_unnamed_addr global i32 4, align 4

; Function Attrs: norecurse nounwind
define void @_ZN9Rectangle10set_valuesEii(%class.Rectangle* nocapture %this, i32 %x, i32 %y) local_unnamed_addr #0 align 2 {
entry:
  %width = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this, i32 0, i32 0
  store i32 %x, i32* %width, align 4, !tbaa !1
  %height = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this, i32 0, i32 1
  store i32 %y, i32* %height, align 4, !tbaa !6
  ret void
}

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* @input1, align 4, !tbaa !7
  %1 = load i32, i32* @input2, align 4, !tbaa !7
  %cmp.i = icmp sgt i32 %0, 0
  %mul.i = mul nsw i32 %1, %0
  %sub.i = sub nsw i32 %0, %1
  %retval.0.i = select i1 %cmp.i, i32 %mul.i, i32 %sub.i
  store i32 %retval.0.i, i32* @res, align 4, !tbaa !7
  ret i32 %retval.0.i
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !3, i64 0}
!2 = !{!"_ZTS9Rectangle", !3, i64 0, !3, i64 4}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!2, !3, i64 4}
!7 = !{!3, !3, i64 0}
