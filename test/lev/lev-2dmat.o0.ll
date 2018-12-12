; ModuleID = 'lev-2dmat.c'
source_filename = "lev-2dmat.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = global [129 x [129 x i32]] zeroinitializer, align 4
@main.str1 = private unnamed_addr constant [128 x i8] c"kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  ", align 1
@main.str2 = private unnamed_addr constant [128 x i8] c"sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting ", align 1

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %size = alloca i32, align 4
  %str1 = alloca [128 x i8], align 1
  %str2 = alloca [128 x i8], align 1
  %left = alloca i32, align 4
  %left_top = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 128, i32* %size, align 4
  %0 = bitcast [128 x i8]* %str1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %0, i8* getelementptr inbounds ([128 x i8], [128 x i8]* @main.str1, i32 0, i32 0), i32 128, i32 1, i1 false)
  %1 = bitcast [128 x i8]* %str2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %1, i8* getelementptr inbounds ([128 x i8], [128 x i8]* @main.str2, i32 0, i32 0), i32 128, i32 1, i1 false)
  store i32 0, i32* %left, align 4
  store i32 0, i32* %left_top, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %size, align 4
  %cmp = icmp sle i32 %2, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %i, align 4
  %arrayidx = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %5
  %arrayidx1 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx, i32 0, i32 0
  store i32 %4, i32* %arrayidx1, align 4
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %i, align 4
  %arrayidx2 = getelementptr inbounds [129 x i32], [129 x i32]* getelementptr inbounds ([129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 0), i32 0, i32 %7
  store i32 %6, i32* %arrayidx2, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %8 = load i32, i32* %i, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond3

for.cond3:                                        ; preds = %for.inc104, %for.end
  %9 = load i32, i32* %i, align 4
  %10 = load i32, i32* %size, align 4
  %cmp4 = icmp sle i32 %9, %10
  br i1 %cmp4, label %for.body5, label %for.end106

for.body5:                                        ; preds = %for.cond3
  store i32 1, i32* %j, align 4
  br label %for.cond6

for.cond6:                                        ; preds = %for.inc101, %for.body5
  %11 = load i32, i32* %j, align 4
  %12 = load i32, i32* %size, align 4
  %cmp7 = icmp sle i32 %11, %12
  br i1 %cmp7, label %for.body8, label %for.end103

for.body8:                                        ; preds = %for.cond6
  %13 = load i32, i32* %i, align 4
  %sub = sub nsw i32 %13, 1
  %arrayidx9 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub
  %14 = load i32, i32* %j, align 4
  %arrayidx10 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx9, i32 0, i32 %14
  %15 = load i32, i32* %arrayidx10, align 4
  %add = add nsw i32 %15, 1
  %16 = load i32, i32* %i, align 4
  %arrayidx11 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %16
  %17 = load i32, i32* %j, align 4
  %sub12 = sub nsw i32 %17, 1
  %arrayidx13 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx11, i32 0, i32 %sub12
  %18 = load i32, i32* %arrayidx13, align 4
  %add14 = add nsw i32 %18, 1
  %cmp15 = icmp slt i32 %add, %add14
  br i1 %cmp15, label %cond.true, label %cond.false54

cond.true:                                        ; preds = %for.body8
  %19 = load i32, i32* %i, align 4
  %sub16 = sub nsw i32 %19, 1
  %arrayidx17 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub16
  %20 = load i32, i32* %j, align 4
  %arrayidx18 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx17, i32 0, i32 %20
  %21 = load i32, i32* %arrayidx18, align 4
  %add19 = add nsw i32 %21, 1
  %22 = load i32, i32* %i, align 4
  %sub20 = sub nsw i32 %22, 1
  %arrayidx21 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub20
  %23 = load i32, i32* %j, align 4
  %sub22 = sub nsw i32 %23, 1
  %arrayidx23 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx21, i32 0, i32 %sub22
  %24 = load i32, i32* %arrayidx23, align 4
  %25 = load i32, i32* %j, align 4
  %sub24 = sub nsw i32 %25, 1
  %arrayidx25 = getelementptr inbounds [128 x i8], [128 x i8]* %str1, i32 0, i32 %sub24
  %26 = load i8, i8* %arrayidx25, align 1
  %conv = zext i8 %26 to i32
  %27 = load i32, i32* %i, align 4
  %sub26 = sub nsw i32 %27, 1
  %arrayidx27 = getelementptr inbounds [128 x i8], [128 x i8]* %str2, i32 0, i32 %sub26
  %28 = load i8, i8* %arrayidx27, align 1
  %conv28 = zext i8 %28 to i32
  %cmp29 = icmp eq i32 %conv, %conv28
  %cond = select i1 %cmp29, i32 0, i32 1
  %add31 = add nsw i32 %24, %cond
  %cmp32 = icmp slt i32 %add19, %add31
  br i1 %cmp32, label %cond.true34, label %cond.false

cond.true34:                                      ; preds = %cond.true
  %29 = load i32, i32* %i, align 4
  %sub35 = sub nsw i32 %29, 1
  %arrayidx36 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub35
  %30 = load i32, i32* %j, align 4
  %arrayidx37 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx36, i32 0, i32 %30
  %31 = load i32, i32* %arrayidx37, align 4
  %add38 = add nsw i32 %31, 1
  br label %cond.end

cond.false:                                       ; preds = %cond.true
  %32 = load i32, i32* %i, align 4
  %sub39 = sub nsw i32 %32, 1
  %arrayidx40 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub39
  %33 = load i32, i32* %j, align 4
  %sub41 = sub nsw i32 %33, 1
  %arrayidx42 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx40, i32 0, i32 %sub41
  %34 = load i32, i32* %arrayidx42, align 4
  %35 = load i32, i32* %j, align 4
  %sub43 = sub nsw i32 %35, 1
  %arrayidx44 = getelementptr inbounds [128 x i8], [128 x i8]* %str1, i32 0, i32 %sub43
  %36 = load i8, i8* %arrayidx44, align 1
  %conv45 = zext i8 %36 to i32
  %37 = load i32, i32* %i, align 4
  %sub46 = sub nsw i32 %37, 1
  %arrayidx47 = getelementptr inbounds [128 x i8], [128 x i8]* %str2, i32 0, i32 %sub46
  %38 = load i8, i8* %arrayidx47, align 1
  %conv48 = zext i8 %38 to i32
  %cmp49 = icmp eq i32 %conv45, %conv48
  %cond51 = select i1 %cmp49, i32 0, i32 1
  %add52 = add nsw i32 %34, %cond51
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true34
  %cond53 = phi i32 [ %add38, %cond.true34 ], [ %add52, %cond.false ]
  br label %cond.end97

cond.false54:                                     ; preds = %for.body8
  %39 = load i32, i32* %i, align 4
  %arrayidx55 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %39
  %40 = load i32, i32* %j, align 4
  %sub56 = sub nsw i32 %40, 1
  %arrayidx57 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx55, i32 0, i32 %sub56
  %41 = load i32, i32* %arrayidx57, align 4
  %add58 = add nsw i32 %41, 1
  %42 = load i32, i32* %i, align 4
  %sub59 = sub nsw i32 %42, 1
  %arrayidx60 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub59
  %43 = load i32, i32* %j, align 4
  %sub61 = sub nsw i32 %43, 1
  %arrayidx62 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx60, i32 0, i32 %sub61
  %44 = load i32, i32* %arrayidx62, align 4
  %45 = load i32, i32* %j, align 4
  %sub63 = sub nsw i32 %45, 1
  %arrayidx64 = getelementptr inbounds [128 x i8], [128 x i8]* %str1, i32 0, i32 %sub63
  %46 = load i8, i8* %arrayidx64, align 1
  %conv65 = zext i8 %46 to i32
  %47 = load i32, i32* %i, align 4
  %sub66 = sub nsw i32 %47, 1
  %arrayidx67 = getelementptr inbounds [128 x i8], [128 x i8]* %str2, i32 0, i32 %sub66
  %48 = load i8, i8* %arrayidx67, align 1
  %conv68 = zext i8 %48 to i32
  %cmp69 = icmp eq i32 %conv65, %conv68
  %cond71 = select i1 %cmp69, i32 0, i32 1
  %add72 = add nsw i32 %44, %cond71
  %cmp73 = icmp slt i32 %add58, %add72
  br i1 %cmp73, label %cond.true75, label %cond.false80

cond.true75:                                      ; preds = %cond.false54
  %49 = load i32, i32* %i, align 4
  %arrayidx76 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %49
  %50 = load i32, i32* %j, align 4
  %sub77 = sub nsw i32 %50, 1
  %arrayidx78 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx76, i32 0, i32 %sub77
  %51 = load i32, i32* %arrayidx78, align 4
  %add79 = add nsw i32 %51, 1
  br label %cond.end95

cond.false80:                                     ; preds = %cond.false54
  %52 = load i32, i32* %i, align 4
  %sub81 = sub nsw i32 %52, 1
  %arrayidx82 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub81
  %53 = load i32, i32* %j, align 4
  %sub83 = sub nsw i32 %53, 1
  %arrayidx84 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx82, i32 0, i32 %sub83
  %54 = load i32, i32* %arrayidx84, align 4
  %55 = load i32, i32* %j, align 4
  %sub85 = sub nsw i32 %55, 1
  %arrayidx86 = getelementptr inbounds [128 x i8], [128 x i8]* %str1, i32 0, i32 %sub85
  %56 = load i8, i8* %arrayidx86, align 1
  %conv87 = zext i8 %56 to i32
  %57 = load i32, i32* %i, align 4
  %sub88 = sub nsw i32 %57, 1
  %arrayidx89 = getelementptr inbounds [128 x i8], [128 x i8]* %str2, i32 0, i32 %sub88
  %58 = load i8, i8* %arrayidx89, align 1
  %conv90 = zext i8 %58 to i32
  %cmp91 = icmp eq i32 %conv87, %conv90
  %cond93 = select i1 %cmp91, i32 0, i32 1
  %add94 = add nsw i32 %54, %cond93
  br label %cond.end95

cond.end95:                                       ; preds = %cond.false80, %cond.true75
  %cond96 = phi i32 [ %add79, %cond.true75 ], [ %add94, %cond.false80 ]
  br label %cond.end97

cond.end97:                                       ; preds = %cond.end95, %cond.end
  %cond98 = phi i32 [ %cond53, %cond.end ], [ %cond96, %cond.end95 ]
  %59 = load i32, i32* %i, align 4
  %arrayidx99 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %59
  %60 = load i32, i32* %j, align 4
  %arrayidx100 = getelementptr inbounds [129 x i32], [129 x i32]* %arrayidx99, i32 0, i32 %60
  store i32 %cond98, i32* %arrayidx100, align 4
  br label %for.inc101

for.inc101:                                       ; preds = %cond.end97
  %61 = load i32, i32* %j, align 4
  %inc102 = add nsw i32 %61, 1
  store i32 %inc102, i32* %j, align 4
  br label %for.cond6

for.end103:                                       ; preds = %for.cond6
  br label %for.inc104

for.inc104:                                       ; preds = %for.end103
  %62 = load i32, i32* %i, align 4
  %inc105 = add nsw i32 %62, 1
  store i32 %inc105, i32* %i, align 4
  br label %for.cond3

for.end106:                                       ; preds = %for.cond3
  ret i32 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #1

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
