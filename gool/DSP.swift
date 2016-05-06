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
    
    // relative dielectric permittivity (RDP) of various soils in approx 100 MHz to 1 GHz range
    // taken from http://home.earthlink.net/~w6rmk/soildiel.htm
    //  and http://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19750018483.pdf
    enum SoilType: Double, CustomStringConvertible {
        case Sandy_dry = 2.25
        case Sandy_5_water = 5.5
        case Sandy_10_water = 8.0
        case Sandy_15_water = 11.9
        case Sandy_20_water = 18.1
        case Loamy_dry = 3.5
        case Loamy_5_water = 5.0
        case Loamy_12_water = 10.0
        case Loamy_20_water = 22.0
        case Clay_dry = 2.38
        case Clay_10_water = 8.5
        case Clay_20_water = 12.0
        
        var description: String {
            switch self {
            case .Sandy_dry: return "Sandy soil (very dry)"
            case .Sandy_5_water: return "Sandy soil (dry)"
            case .Sandy_10_water: return "Sandy soil (damp)"
            case .Sandy_15_water: return "Sandy soil (wet)"
            case .Sandy_20_water: return "Sandy soil (very wet)"
            case .Loamy_dry: return "Loamy soil (very dry)"
            case .Loamy_5_water: return "Loamy soil (dry)"
            case .Loamy_12_water: return "Loamy soil (damp)"
            case .Loamy_20_water: return "Loamy soil (wet)"
            case .Clay_dry: return "Clay (dry)"
            case .Clay_10_water: return "Clay (damp)"
            case .Clay_20_water: return "Clay (wet)"
            }
        }
    }
    
    
    
    static let FWHM = 2.35482
    static let C_m_s = 299_792_458.0        // speed of light in m/s
    static let C_nm_s = C_m_s/1e9           // speed of light in nm/s
    static let max8Bit = Double(UInt8.max)
    static let max16Bit = Double(UInt16.max)
    
    
    static func repack(bytes: [UInt8], is8Bit: Bool) -> [UInt16] {
        var repacked: [UInt16]
        
        if is8Bit {
            repacked = [UInt16](count: bytes.count, repeatedValue: 0)
            for i in 0...bytes.count-1 {
                let val = UInt16(bytes[i])
                repacked.append(val + (val<<8))
                // Each 8-bit val could come from 128 distinct 16-bit values
                // scaled so 0->0, 128->32896, 255->65535
                // Could also randomly select one of the 128
            }
        }
        else { // may be efficient way to recast in Objective-C
            let n = bytes.count / 2
            repacked = [UInt16](count: n, repeatedValue: 0)
            
            for i in 0...n {
                repacked[i] = UInt16(bytes[2*i]) << 8
                repacked[i] += UInt16(bytes[2*i + 1])
            }
        }
        
        return repacked
    }
    
    class func dataAsDoubles(trace: GPRTrace) -> [Double] {
        return trace.data.map({(val: UInt16) -> Double in Double(val)})
    }
    
    // Assuming constant material RDP and ignoring attenuation, determines
    //  change in reflection depth between successive samples
    class internal func dDepth(trace: GPRTrace, settings: GPRSettings) -> Double {
        return estDepth_ns(settings.𝚫T, avgRDP: settings.baseRdp)
    }
    
    //TODO: stubbed
    class internal func filter(signal: GPRTrace, settings: GPRSettings) -> [UInt16] {
        // plan: select transforms and/or filters based on mode
        
        return signal.data
    }
    
    // does not check that traces match each other; just stacks their data
    static func stackData(traces : [GPRTrace]) -> [UInt16] {
        // consider using vDSP_vavlin or _vavlinD
        let n = UInt16(traces.count), len = traces[0].data.count
        var stackedData = [UInt16](count: len, repeatedValue: 0)
        var remainder = [UInt16](count: len, repeatedValue: 0)
        
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
    
    static func findEdges(vector: [Double], minAmp: Double) -> [Bool] {
        let mid = Double(1<<15)
        
        let n = vector.count
        var edge = [Bool](count: n, repeatedValue: false)
        
        let smoothedDeriv = smoothFourier(deriv(vector, dx: 1.0), portion: 0.2)
        //{(m1: Material, m2: Material) -> Bool in m1.isBetterGuess(m2, rdp: rdp)}
        let sortedDerivs = smoothedDeriv.sort( {(d1: Double, d2: Double) -> Bool in abs(d1) < abs(d2)} )
        let minSlope = sortedDerivs[Int(Double(n) * 0.85)]
        
        var i = 1
        while i < n {
            if abs(smoothedDeriv[i]) >= minSlope && abs(vector[i] - mid) > minAmp {
                edge[i] = true
                i += 1
                while i < n && (abs(smoothedDeriv[i]) >= minSlope || abs(vector[i] - mid) > minAmp) {
                    edge[i] = true
                    i+=1
                }
            }
            else {
                i += 1
            }
        }
        
        return edge
    }
    
    static func findPeaks(vector: [Double], dx: Double, minSlope: Double, minAmplitude: Double) -> [Peak] {
        // 1) Find derivative
        // 2) Smooth derivative
        // 3) Find zero crossings in smoothed derivative
        
        // TODO: update to determine (or be passed) values for optimal smoothing ratio
        let smoothedDeriv = smooth(deriv(vector, dx: dx), width: 3)
        let n = vector.count
        let mid = Double(1<<15)
        let ampCheck = minAmplitude < mid ? minAmplitude : Double(1<<12)
        
        
        var peaks = [Peak]()
        
        for i in 1 ... n-2 {
            // zero crossing
            if (smoothedDeriv[i-1] >= 0 && smoothedDeriv[i] <= 0 && smoothedDeriv[i-1] != smoothedDeriv[i])
               || (smoothedDeriv[i-1] <= 0 && smoothedDeriv[i] >= 0 && smoothedDeriv[i-1] != smoothedDeriv[i]) {
                // meets amplitude threshold
                if abs(vector[i] - mid) >= ampCheck || abs(vector[i+1] - mid) >= ampCheck {
                    // meets slope threshold
                    let slope = max(abs(smoothedDeriv[i+1]-smoothedDeriv[i]), abs(smoothedDeriv[i]-smoothedDeriv[i-1])) // use dx?
                    if slope >= minSlope {
                        // not sure the best way to determine range
                        let from = max(0, i-10), to = min(n-1, i+10)
                        peaks.append(getPeak(vector, dx: dx, from: from, to: to, sample: i))
                    }
                }
            }
        }
        
        return peaks
    }
    
    // Uses quadratic least-squares regression to estimate peak attributes
    // There have been problems using this technique with actual data, so we're simplifying it for now
    static private func getPeak(vector: [Double], dx: Double, from: Int, to: Int, sample: Int) -> Peak {
        /*let n = from+1-to
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
        //let sample = Int(round(position/dx))
        let height = a - c*position*position
        let width = FWHM/sqrt(-2*c)
        */
        let position = dx * Double(sample)
        let height = max(abs(vector[sample]-vector[sample-1]), vector[sample+1]-vector[sample])
        return Peak(sample: sample, pos: position, h: height, w: 2)
    }
    
    // Returns a list of possible materials for this item
    static func guessMaterials(peak: Peak, settings: GPRSettings, base: Double, reflection: Double) -> [Material] {
        var guesses = [Material]()
        let rdp = estimateRDP(settings.baseRdp, baseIntensity: base, reflectedIntensity: reflection)
        
        for material in Material.MaterialList {
            if rdp >= material.minRDP && rdp <= material.maxRDP {
                guesses.append(material)
            }
        }
        
        guesses.sortInPlace({(m1: Material, m2: Material) -> Bool in m1.isBetterGuess(m2, rdp: rdp)})
        
        return guesses
    }
    
    // linearly approximates first derivative of signal
    static func deriv(vector: [Double], dx: Double) -> [Double] {
        let n = vector.count
        var deriv = [Double].init(count: n, repeatedValue: 0.0)
        
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
        
        if w <= n-w {
            for i in w ... n-w {
                for j in -w ... w-1 {
                    sum += j < 0 ? -vector[i+j] : vector[i+j]
                }
                
                res[i] = sum/div
            }
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
    
    
    // Smooths a signal via Fourier Transform. portion of highest frequencies are eliminated
    static func smoothFourier(vector: [Double], portion: Float) -> [Double] {
        // FFT setup
        let n = vector.count
        var real = [Double](vector)
        if portion >= 1.0 {
            return real
        }
        var imaginary = [Double](count: n, repeatedValue: 0.0)
        
        var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
        
        let log2n = vDSP_Length(ceil(log2(Float(n))))
        let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetupD(log2n, radix)
        vDSP_fft_zipD(weights, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // note that vDSP implementation of real FFT yields doubled values. No fix needed for complex
        // splitComplex now holds the Fourier transform of signal
        // zero out high frequencies to remove noise
        let clearInd = Int(ceil(Float(n)*portion))
        for i in clearInd...n-1 {
            real[i] = 0.0
            imaginary[i] = 0.0
        }
        
        // inverse FFT
        vDSP_fft_zipD(weights, &splitComplex, 1, log2n, FFTDirection(FFT_INVERSE))
        
        // cleanup
        vDSP_destroy_fftsetupD(weights)
        
        // vDSP complex inverse FFT yields actual values times n
        let nd = Double(n)
        return real.map({(x: Double) -> Double in return x/nd})
    }
    
    
    // Given expected average RDP of medium, what reflection depth is indicated by a sample at time t?
    static func estDepth_s(t: Double, avgRDP: Double) -> Double {
        return C_m_s * t / (2.0 * sqrt(avgRDP))
    }
    
    // same as estDepth_s but with time in nanoseconds instead of seconds
    static func estDepth_ns(t: Double, avgRDP: Double) -> Double {
        return C_nm_s * t / (2.0 * sqrt(avgRDP))
    }
    
    
    // Electromagnetic waves are reflected at interface of two materials based on their relative
    //  dielectric permittivities (RDPs). Given expected RDP of first material, expected wave intensity
    //  at interface, and measured reflected intensity, this yields the expected RDP of second material.
    // This function does not account for attenuation/loss; all such adjustments must be made before calling.
    // Returned value of > ~80 indicates second material is a conductor.
    static func estimateRDP(baseRDP: Double, baseIntensity: Double, reflectedIntensity: Double) -> Double {
        let plus = baseIntensity + reflectedIntensity
        let diff = baseIntensity - reflectedIntensity
        
        return baseRDP * (plus*plus) / (diff*diff)
    }
    
    static func subAvg(inout vector: [Double]) {
        let n = vector.count
        
        var sum = 0.0
        vDSP_sveD(&vector, 1, &sum, vDSP_Length(n))
        
        let avg = sum / Double(n)
        
        for i in 0...n-1 {
            vector[i] -= avg
        }
    }
    
    static func subAvg2D(inout vectors: [[Double]]) {
        let samples = vectors[0].count
        var avgs = [Double]()
        
        for i in 0...samples-1 {
            var sum = 0.0
            for vector in vectors {
                sum += vector[i]
            }
            avgs.append(sum/Double(samples))
        }
        
        for var trace in vectors {
            for i in 0...samples-1 {
                trace[i] -= avgs[i]
            }
        }
    }
    
    
    // Cubic spline function. results of interpolation are stored in yNew
    // based on JL_UTIL.C Spline() by Jeff Lucius, USGS Crustal Imaging and Characterization Team
    static func spline(xNew: [Double], yNewValues: [Double], xValues: [Double], yValues: [Double]) {
        let n = xValues.count
        var x = [Double].init(count: n, repeatedValue: 0.0),
            y = [Double].init(count: n, repeatedValue: 0.0),
            yNew = [Double].init(count: n, repeatedValue: 0.0)
        
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
    var sampleNumber: Int
    var trace: GPRTrace?
    
    init(sample: Int, pos: Double, h: Double, w: Double, tr: GPRTrace? = nil) {
        sampleNumber = sample
        position = pos
        height = h
        width = w
        trace = tr
    }
}