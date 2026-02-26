; memset_var: variable-length memset via function call
; clear_and_sum(ptr d, i32 bytes): memset d to 0, return d->a + d->b + d->c
; main: set {10,20,30}, call clear_and_sum → 0; return 0+42 = 42

%struct.Data = type { i32, i32, i32 }

define i32 @clear_and_sum(ptr %0, i32 %1) {
  %3 = alloca ptr
  %4 = alloca i32
  store ptr %0, ptr %3
  store i32 %1, ptr %4
  %5 = load ptr, ptr %3
  %6 = load i32, ptr %4
  call void @llvm.memset.p0.i32(ptr %5, i8 0, i32 %6, i1 false)
  %7 = load ptr, ptr %3
  %8 = getelementptr inbounds %struct.Data, ptr %7, i32 0, i32 0
  %9 = load i32, ptr %8
  %10 = getelementptr inbounds %struct.Data, ptr %7, i32 0, i32 1
  %11 = load i32, ptr %10
  %12 = add nsw i32 %9, %11
  %13 = getelementptr inbounds %struct.Data, ptr %7, i32 0, i32 2
  %14 = load i32, ptr %13
  %15 = add nsw i32 %12, %14
  ret i32 %15
}

declare void @llvm.memset.p0.i32(ptr, i8, i32, i1)

define i32 @main() {
  %1 = alloca %struct.Data
  %2 = getelementptr inbounds %struct.Data, ptr %1, i32 0, i32 0
  store i32 10, ptr %2
  %3 = getelementptr inbounds %struct.Data, ptr %1, i32 0, i32 1
  store i32 20, ptr %3
  %4 = getelementptr inbounds %struct.Data, ptr %1, i32 0, i32 2
  store i32 30, ptr %4
  %5 = call i32 @clear_and_sum(ptr %1, i32 12)
  %6 = add nsw i32 %5, 42
  ret i32 %6
}
