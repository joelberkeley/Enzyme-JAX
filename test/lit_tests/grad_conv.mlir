// RUN: enzymexlamlir-opt %s --enzyme-wrap="infn=main outfn= retTys=enzyme_dup argTys=enzyme_dup,enzyme_dup mode=ForwardMode" | FileCheck %s --check-prefix=FORWARD
// TODO: enzymexlamlir-opt %s --enzyme-wrap="infn=main outfn= retTys=enzyme_active argTys=enzyme_active,enzyme_active mode=ReverseModeCombined" --canonicalize --remove-unnecessary-enzyme-ops | FileCheck %s --check-prefix=REVERSE

module {
  func.func @main(%808: tensor<8x66x66x512xf32>, %arg100: tensor<3x3x512x512xf32>) -> tensor<8x64x64x512xf32> {
    %809 = "stablehlo.convolution"(%808, %arg100) <{batch_group_count = 1 : i64, dimension_numbers = #stablehlo.conv<[b, 0, 1, f]x[0, 1, i, o]->[b, 0, 1, f]>, feature_group_count = 1 : i64, lhs_dilation = array<i64: 1, 1>, padding = dense<0> : tensor<2x2xi64>, precision_config = [#stablehlo<precision DEFAULT>, #stablehlo<precision DEFAULT>], rhs_dilation = array<i64: 1, 1>, window_reversal = array<i1: false, false>, window_strides = array<i64: 1, 1>}> : (tensor<8x66x66x512xf32>, tensor<3x3x512x512xf32>) -> tensor<8x64x64x512xf32>
    return %809 : tensor<8x64x64x512xf32>
  }
}


// FORWARD:  func.func @main(%arg0: tensor<8x66x66x512xf32>, %arg1: tensor<8x66x66x512xf32>, %arg2: tensor<3x3x512x512xf32>, %arg3: tensor<3x3x512x512xf32>) -> (tensor<8x64x64x512xf32>, tensor<8x64x64x512xf32>) {
// FORWARD-NEXT:    %0 = stablehlo.convolution(%arg1, %arg2) dim_numbers = [b, 0, 1, f]x[0, 1, i, o]->[b, 0, 1, f], window = {stride = [1, 1], pad = {{\[\[}}0, 0], [0, 0]], lhs_dilate = [1, 1], rhs_dilate = [1, 1], reverse = [false, false]} {batch_group_count = 1 : i64, feature_group_count = 1 : i64, precision_config = [#stablehlo<precision DEFAULT>, #stablehlo<precision DEFAULT>]} : (tensor<8x66x66x512xf32>, tensor<3x3x512x512xf32>) -> tensor<8x64x64x512xf32>
// FORWARD-NEXT:    %1 = stablehlo.convolution(%arg0, %arg3) dim_numbers = [b, 0, 1, f]x[0, 1, i, o]->[b, 0, 1, f], window = {stride = [1, 1], pad = {{\[\[}}0, 0], [0, 0]], lhs_dilate = [1, 1], rhs_dilate = [1, 1], reverse = [false, false]} {batch_group_count = 1 : i64, feature_group_count = 1 : i64, precision_config = [#stablehlo<precision DEFAULT>, #stablehlo<precision DEFAULT>]} : (tensor<8x66x66x512xf32>, tensor<3x3x512x512xf32>) -> tensor<8x64x64x512xf32>
// FORWARD-NEXT:    %2 = stablehlo.add %0, %1 : tensor<8x64x64x512xf32>
// FORWARD-NEXT:    %3 = stablehlo.convolution(%arg0, %arg2) dim_numbers = [b, 0, 1, f]x[0, 1, i, o]->[b, 0, 1, f], window = {stride = [1, 1], pad = {{\[\[}}0, 0], [0, 0]], lhs_dilate = [1, 1], rhs_dilate = [1, 1], reverse = [false, false]} {batch_group_count = 1 : i64, feature_group_count = 1 : i64, precision_config = [#stablehlo<precision DEFAULT>, #stablehlo<precision DEFAULT>]} : (tensor<8x66x66x512xf32>, tensor<3x3x512x512xf32>) -> tensor<8x64x64x512xf32>
// FORWARD-NEXT:    return %3, %2 : tensor<8x64x64x512xf32>, tensor<8x64x64x512xf32>
// FORWARD-NEXT:  }

// TODO
// REVERSE:  func.func @main(%arg0: tensor<2x3xf32>, %arg1: tensor<18x27xf32>) -> tensor<2x3xf32> {
// REVERSE-NEXT:    %[[icst:.+]] = arith.constant dense<0.000000e+00> : tensor<18x27xf32>
// REVERSE-NEXT:    %[[icst0:.+]] = arith.constant dense<0.000000e+00> : tensor<2x3xf32>
// REVERSE-NEXT:    %[[i0:.+]] = arith.addf %arg1, %[[icst]] : tensor<18x27xf32>
// REVERSE-NEXT:    %[[i1:.+]] = stablehlo.slice %[[i0]] [5:7, 7:14:3] : (tensor<18x27xf32>) -> tensor<2x3xf32>
// REVERSE-NEXT:    %[[i2:.+]] = arith.addf %[[i1]], %[[icst0]] : tensor<2x3xf32>
// REVERSE-NEXT:    return %[[i2]] : tensor<2x3xf32>
// REVERSE-NEXT:  }
