; ModuleID = '1.cpp'
source_filename = "1.cpp"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

%class.Rectangle = type { i32, i32 }

$_ZN9Rectangle4areaEv = comdat any

@res = global i32 0, align 4
@input1 = global i32 3, align 4
@input2 = global i32 4, align 4

; Function Attrs: noinline nounwind
define void @_ZN9Rectangle10set_valuesEii(%class.Rectangle* %this, i32 %x, i32 %y) #0 align 2 {
entry:
  %this.addr = alloca %class.Rectangle*, align 4
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  store %class.Rectangle* %this, %class.Rectangle** %this.addr, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  %this1 = load %class.Rectangle*, %class.Rectangle** %this.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %width = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 0
  store i32 %0, i32* %width, align 4
  %1 = load i32, i32* %y.addr, align 4
  %height = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 1
  store i32 %1, i32* %height, align 4
  ret void
}

; Function Attrs: noinline norecurse
define i32 @main() #1 {
entry:
  %retval = alloca i32, align 4
  %rect = alloca %class.Rectangle, align 4
  store i32 0, i32* %retval, align 4
  %0 = load i32, i32* @input1, align 4
  %1 = load i32, i32* @input2, align 4
  call void @_ZN9Rectangle10set_valuesEii(%class.Rectangle* %rect, i32 %0, i32 %1)
  %call = call i32 @_ZN9Rectangle4areaEv(%class.Rectangle* %rect)
  store i32 %call, i32* @res, align 4
  %2 = load i32, i32* @res, align 4
  ret i32 %2
}

; Function Attrs: noinline nounwind
define linkonce_odr i32 @_ZN9Rectangle4areaEv(%class.Rectangle* %this) #0 comdat align 2 {
entry:
  %retval = alloca i32, align 4
  %this.addr = alloca %class.Rectangle*, align 4
  store %class.Rectangle* %this, %class.Rectangle** %this.addr, align 4
  %this1 = load %class.Rectangle*, %class.Rectangle** %this.addr, align 4
  %width = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 0
  %0 = load i32, i32* %width, align 4
  %cmp = icmp sgt i32 %0, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %width2 = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 0
  %1 = load i32, i32* %width2, align 4
  %height = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 1
  %2 = load i32, i32* %height, align 4
  %mul = mul nsw i32 %1, %2
  store i32 %mul, i32* %retval, align 4
  br label %return

if.else:                                          ; preds = %entry
  %width3 = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 0
  %3 = load i32, i32* %width3, align 4
  %height4 = getelementptr inbounds %class.Rectangle, %class.Rectangle* %this1, i32 0, i32 1
  %4 = load i32, i32* %height4, align 4
  %sub = sub nsw i32 %3, %4
  store i32 %sub, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.else, %if.then
  %5 = load i32, i32* %retval, align 4
  ret i32 %5
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline norecurse "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
