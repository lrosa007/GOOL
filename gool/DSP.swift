//
//  DSP.swift
//  gool
//
//  Digital Signal Processing module
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation
import Accelerate

class DSP {
    
    // relative dielectric permittivity (RDP) of various soils at 100 MHz-2 GHz
    // taken from http://home.earthlink.net/~w6rmk/soildiel.htm
    static let RDP_SANDY_DRY = 2.550,
               RDP_SANDY_2_18_WATER = 2.500,
               RDP_SANDY_3_88_WATER  = 4.500,
               RDP_SANDY_18_88_WATER = 2.00,
               RDP_LOAMY_DRY = 2.470,
               RDP_LOAMY_2_2_WATER = 3.500,
               RDP_LOAMY_13_77_WATER = 2.00,
               RDP_CLAY_DRY = 2.380 // varies more with frequency than other soil types
    
    static let FWHM = 2.35482
    
    //TODO: stubbed
    class internal func filter(signal: [UInt8], mode: GPRMode) -> [UInt8] {
        // plan: select transforms and/or filters based on mode
        
        return signal
    }
    
    static func radon(image: [[UInt8]]) -> [[Double]] {
        // creates matrix of 1D projections at theta in 1-180 degrees
        var sinogram = [[Double]]()
        
        for theta in 0...180 {
            let mRotated = affineMatrixRotation(image, theta: Double(theta))
            sinogram[theta] = sum(mRotated)
        }
        
        return sinogram
    }
    
    // used in radon transform
    static func affineMatrixRotation(mtx: [[UInt8]], theta: Double) -> [[Double]] {
        //TODO
        return [[Double]]()
    }
    
    //used in radon transform
    static internal func sum(matrix: [[Double]], cols:Bool = true) -> [Double] {
        let len = cols ? matrix[0].count : matrix.count
        var sum = [Double]()
        
        for i in 0...len-1 {
            if cols {
                for j in 0...matrix.count-1 {
                    sum[i] += matrix[j][i]
                }
            }
            else {
                for j in 0...matrix[0].count-1 {
                    sum[i] += matrix[i][j]
                }
            }
        }
        
        return sum
    }
    
    // does not check that traces match each other; just stacks their data
    static func stackData(traces : [GPRTrace]) -> [UInt8] {
        // consider using vDSP_vavlin or _vavlinD
        let n = UInt8(traces.count), len = traces[0].data.count
        var stackedData = [UInt8](count: len, repeatedValue: 0)
        var remainder = [UInt8](count: len, repeatedValue: 0)
        
        for trace in traces {
            for (index, value) in trace.data.enumerate() {
                stackedData[index] += value/n
                remainder[index] += value%n
            }
        }
        
        for (index, value) in remainder.enumerate() {
            //currently just tries to round appropriately;
            // perhaps 2 or 4 bytes could be averaged at a time
            stackedData[index] += (value + n/2)/n
        }
        
        return stackedData
    }
    
    static func findPeaks(vector: [Double], dx: Double, minSlope: Double, minAmplitude: Double) -> [Peak] {
        // 1) Find derivative
        // 2) Smooth derivative
        // 3) Find zero crossings in smoothed derivative
        
        // TODO: update to determine (or be passed) values for optimal smoothing ratio
        let smoothedDeriv = smooth(deriv(vector, dx: dx), width: 3)
        let n = vector.count
        
        var peaks = [Peak]()
        
        for i in 1 ... n-2 {
            // zero crossing
            if smoothedDeriv[i-1] > 0 && smoothedDeriv[i] < 0 {
                // meets amplitude threshold
                if vector[i] > minAmplitude || vector[i+1] > minAmplitude {
                    // meets slope threshold
                    let slope = (smoothedDeriv[i+1]-smoothedDeriv[i-1])/2.0 // use dx?
                    if slope >= minSlope {
                        // not sure the best way to determine range
                        let from = max(0, i-10), to = min(n-1, i+10)
                        peaks.append(getPeak(vector, dx: dx, from: from, to: to))
                    }
                }
            }
        }
        
        return peaks
    }
    
    // Uses quadratic least-squares regression to estimate peak attributes
    static private func getPeak(vector: [Double], dx: Double, from: Int, to: Int) -> Peak {
        let n = from+1-to
        var sumX = 0.0,
            sumY = 0.0,
            sumXY = 0.0,
            sumX2 = 0.0,
            sumX3 = 0.0,
            sumX4 = 0.0,
            sumX2Y = 0.0
        
        for i in from...to {
            let x = Double(i) * dx,
                y = vector[i]
            sumY += y
            sumX += x
            sumXY += x*y
            sumX2 += x*x
            sumX2Y += x*x*y
            sumX3 += x*x*x
            sumX4 += x*x*x*x
        }
        
        let nd = Double(n)
        
        var D = (nd*sumX2*sumX4)
            D += (2*sumX*sumX2*sumX3)
            D -= (sumX2*sumX2*sumX2*sumX4)
            D -= (nd*sumX3*sumX3)
        
        var a = nd*sumX2*sumX2Y
            a += sumX*sumX3*sumY
            a += sumX*sumX2*sumXY
            a -= sumX2*sumX2*sumY
            a -= sumX*sumX*sumX2Y
            a -= nd*sumX3*sumXY
            a /= D
        
        var b = nd*sumX4*sumXY
            b += sumX*sumX2*sumX2Y
            b += sumX2*sumX3*sumY
            b -= sumX2*sumX2*sumXY
            b -= sumX*sumX4*sumY
            b -= nd*sumX3*sumX2Y
            b /= D
        
        var c = sumX2*sumX4*sumY
            c += sumX2*sumX3*sumXY
            c += sumX*sumX3*sumX2Y
            c -= sumX2*sumX2*sumX2Y
            c -= sumX*sumX4*sumXY
            c -= sumX3*sumX3*sumY
            c /= D
        
        let position = -b/(2*c)
        let height = a - c*position*position
        let width = FWHM/sqrt(-2*c)
        
        return Peak(pos: position, h: height, w: width)
    }
    
    // linearly approximates first derivative of signal
    static func deriv(vector: [Double], dx: Double) -> [Double] {
        let n = vector.count
        var deriv = [Double]()
        
        deriv[0] = 0
        for i in 1 ... n-2 {
            deriv[i] = (vector[i+1]-vector[i-1])/(2*dx)
        }
        
        return deriv
    }
    
    // smooth signal with variable signal width (width must be odd)
    static func smooth(vector: [Double], width: Int) -> [Double] {
        let w: Int
        if width < 1 {
            w = 1
        } else if width % 2 == 0 {
            w = 3
        } else {
            w = width
        }
        
        let wf = Double(w), div = wf*wf
        let n = vector.count
        var res = [Double].init(count: n, repeatedValue: 0.0)
        
        var sum:Double = wf * vector[w-1]
        //initial sum value
        for i in 1 ... w-1 {
            sum += (wf-Double(i)) * (vector[w-1-i] + vector[w-1+i])
        }
        
        res[w-1] = sum/div
        
        for i in w ... n-1-w {
            for j in -w ... w-1 {
                sum += j < 0 ? -vector[i+j] : vector[i+j]
            }
            
            res[i] = sum/div
        }
        
        return res
    }
    
    // in-place triangular smooth
    static func smooth(inout vector: [Double]) {
        let n = vector.count
        
        var vim2 = vector[0],
            vim1 = vector[1],
            vi   = vector[2],
            vip1 = vector[3],
            vip2 = vector[4],
            sum = vim2 + 2*vim1 + 3*vi + 2*vip1 + vip2,
            i = 2
        
        vector[i] = sum
        
        while i+3 < n {
            i += 1
            let next = sum/9.0
            sum -= vim2; vim2 = vim1
            sum -= vim1; vim1 = vi
            sum -= vi;   vi = vip1
            sum += vip1; vip1 = vip2
            sum += vip2; vip2 = vector[i+2]
            
            vector[i] = next
        }
    }
    
    // Cubic spline function. results of interpolation are stored in yNew
    // based on JL_UTIL.C Spline() by Jeff Lucius, USGS Crustal Imaging and Characterization Team
    static func spline(xNew: [Double], yNewValues: [Double], xValues: [Double], yValues: [Double]) {
        var x = [Double](), y = [Double](), yNew = [Double]()
        let n = xValues.count
        
        for i in 0...n-1 {
            x[i] = xValues[i]
            y[i] = yValues[i]
            yNew[i] = yNewValues[i]
        }
        
        // reverse sequence if necessary
        if(x[n-1] < x[0]) {
            var temp = 0.0
            
            for i in 0...n/2-1 {
                temp = x[i]
                x[i] = x[n-1-i]
                x[n-1-i] = temp
                
                temp = y[i]
                y[i] = y[n-1-i]
                y[n-1-i] = temp
            }
        }
        
        var s = [Double](), g = [Double](), work = [Double](count: n, repeatedValue: 0.0)
        
        s.append(0.0)
        g.append(0.0)
        
        for i in 1...n-2 {
            var dx, dx2: Double
            
            dx = x[i]-x[i-1]
            dx2 = x[i+1]-x[i-1]
            work[i] = (dx)/(dx2)/2
            
            let t = ((y[i+1]-y[i])/(dx) - (y[i]-y[i-1])/(dx))/(dx2)
            
            s.append(2.0*t)
            g.append(3.0*t)
        }
        
        s.append(0.0)
        g.append(0.0)
        
        let w = 8.0 - 4.0*sqrt(3.0), epsilon = 1.0e-6
        var u = 0.0
        
        repeat {
            u = 0.0
            for i in 1...n-2 {
                let xx = work[i]
                let t = w*(g[i]-s[i] - xx*s[i] - (0.5-xx)*s[i+1])
                
                u = max(u, abs(t))
                s[i] += t
            }
        } while(u >= epsilon)
        
        for i in 0...n-1 {
            g[i] = (s[i+1] - x[i]) / (x[i+1] - x[i])
        }
        
        // interpolation
        var i = 0
        
        for j in 0...n-1 {
            let t = xNew[j]
            repeat {i += 1} while (i < n-1 && t > x[i])
            
            i -= 1
            
            let h = xNew[j] - x[i]
            var temp: Double = (xNew[j]-x[i+1])/6.0
            
            temp *= (2*s[i] + s[i+1] + h*g[i])
            temp += (y[i+1]-y[i])/(x[i+1]-x[i]) + y[i]
            yNew[j] = h * temp
        }
    }
}

class Peak {
    var position, height, width: Double
    
    init(pos: Double, h: Double, w: Double) {
        position = pos
        height = h
        width = w
    }
}