//
//  LocToTime.swift
//  Sunsketcher
//
//  Created by Tameka Ferguson on 9/12/23.
//


/*
// Swift Solar Eclipse Calculator
 This code was translated to Swift from Java by Tameka Ferguson.
 
 For the original code this was based on:
 // This code is being released under the terms of the GNU General Public
 // License (http://www.gnu.org/copyleft/gpl.html).
 // The source code this file is based on was created by
 // chris@obyrne.com  and  fred.espenak@nasa.gov
 // If you would like to use or modify this code, send them,
 // as well as travis.peden194@topper.wku.edu, an email about it.
 //
 // Code obtained from http://eclipse.gsfc.nasa.gov/JSEX/JSEX-index.html
 // and http://www.chris.obyrne.com:80/Eclipses/calculator.html (now 404'd,
 // can be found at http://web.archive.org/web/20071006051658/http://www.chris.obyrne.com:80/Eclipses/calculator.html
 //
 
 Java Solar Eclipse Explorer
 Java Version 1 by Travis Peden - 2022.
 Javascript Version 1 by Chris O'Byrne and Fred Espenak - 2007.
 (based on "Eclipse Calculator" by Chris O'Byrne and Stephen McCann - 2003)

 This file (LocToTime.swift) is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 */


import Foundation
import SwiftUI


//only makes sure that the user is in the eclipse path
public class LocToTime {
    
    //let locationManager: LocationManager
    
    // Holds the observational constants that can be used for the location of the eclipse
    var obsvconst: [Double] = [Double](repeating: 0.0, count: 7)
    
    //Aug. 12, 2026 | SPAIN/ICELAND
    public var elements: [Double] = [2461265.24104, 18.0, -3.0, 3.0,   69.1,   69.1,
                                   0.47551399,   0.51892489,  -0.00007730,  -0.00000804,
                                   0.77118301,  -0.23016800,  -0.00012460,   0.00000377,
                                   14.79666996,  -0.01206500,  -0.00000300,
                                   88.74778748,  15.00308990,   0.00000000,
                                   0.53795499,   0.00009390,  -0.00001210,
                                   -0.00814200,   0.00009350,  -0.00001210,
                                    0.00461410,   0.00459110]
    
    //Aug. 21, 2017 (for testing)
    /*public var elements: [Double] = [2457987.268521,  18.0, -4.0, 4.0, 70.3, 70.3,
                                     -0.1295710,   0.5406426, -2.940e-05, -8.100e-06,
                                     0.4854160,  -0.1416400, -9.050e-05,  2.050e-06,
                                     11.8669596,  -0.0136220, -2.000e-06,
                                     89.2454300,  15.0039368,  0.000e-00,
                                     0.5420930,   0.0001241, -1.180e-05,
                                     -0.0040250,   0.0001234, -1.170e-05,
                                     0.0046222,   0.0045992]*/
 
    // For Apr 8, 2024 | Set iPhone time to ~12:56PM
    /*public var elements: [Double] = [2460409.262841, 18.0, -4.0, 4.0, 69.2, 69.2,    //Date, hour of greatest eclipse, delta T
                                     -0.3182485,    0.5117099,  0.0000326, -0.0000084,                                //x
                                      0.2197639,    0.2709581, -0.0000594, -0.0000047,                                //y
                                      7.5861838,    0.0148444, -0.0000017,                                            //d
                                     89.591230,    15.004082,  -8.380e-07,                                            //mu
                                      0.5358323,    0.0000618, -1.276e-05,                                            //l1
                                     -0.0102736,    0.0000615, -1.269e-05,                                            //l2
                                      0.0046683,    0.0046450]*/
    
    //
    // Eclipse circumstances
    //  (0) Event type (C1=-2, C2=-1, Mid=0, C3=1, C4=2)
    //  (1) t
    // -- time-only dependent circumstances (and their per-hour derivatives) follow --
    //  (2) x
    //  (3) y
    //  (4) d
    //  (5) sin d
    //  (6) cos d
    //  (7) mu
    //  (8) l1
    //  (9) l2
    // (10) dx
    // (11) dy
    // (12) dd
    // (13) dmu
    // (14) dl1
    // (15) dl2
    // -- time and location dependent circumstances follow --
    // (16) h
    // (17) sin h
    // (18) cos h
    // (19) xi
    // (20) eta
    // (21) zeta
    // (22) dxi
    // (23) deta
    // (24) u
    // (25) v
    // (26) a
    // (27) b
    // (28) l1'
    // (29) l2'
    // (30) n^2
    // -- observational circumstances follow --
    // (31) p
    // (32) alt
    // (33) q
    // (34) v
    // (35) azi
    // (36) m (mid eclipse only) or limb correction applied (where available!)
    // (37) magnitude (mid eclipse only)
    // (38) moon/sun (mid eclipse only)
    // (39) calculated local event type for a transparent earth (mid eclipse only)
    //      (0 = none, 1 = partial, 2 = annular, 3 = total)
    // (40) event visibility
    //      (0 = above horizon, 1 = below horizon, 2 = sunrise, 3 = sunset, 4 = below horizon, disregard)
    //
    
    //static var month: [String] = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    
    var c1: [Double] = [Double](repeating: 0.0, count: 41)
    var c2: [Double] = [Double](repeating: 0.0, count: 41)
    var mid: [Double] = [Double](repeating: 0.0, count: 41)
    var c3: [Double] = [Double](repeating: 0.0, count: 41)
    var c4: [Double] = [Double](repeating: 0.0, count: 41)
    
    //var currentTimePeriod: String = ""
    //private var loadedTimePeriods: [String] = []
    
    // Populate the circumstances array with the time-only dependent circumstances (x, y, d, m, ...)
    func timeDependent(_ circumstances: inout [Double]) -> [Double] {
        //print("timeDependent called")
        
        var type: Double
        var index: Int
        var t: Double
        var ans: Double
        
        t = circumstances[1]
        index = Int(obsvconst[6])
        
        //Calculate x
        ans = elements[9 + index] * t + elements[8 + index]
        ans = ans * t + elements[7 + index]
        ans = ans * t + elements[6 + index]
        circumstances[2] = ans
        
        // Calculate dx
        ans = 3.0 * elements[9 + index] * t + 2.0 * elements[8 + index]
        ans = ans * t + elements[7 + index]
        circumstances[10] = ans
        
        // Calculate y
        ans = elements[13+index] * t + elements[12 + index]
        ans = ans * t + elements[11 + index]
        ans = ans * t + elements[10 + index]
        circumstances[3] = ans
        
        // Calculate dy
        ans = 3.0 * elements[13 + index] * t + 2.0 * elements[12 + index]
        ans = ans * t + elements[11 + index]
        circumstances[11] = ans
        
        // Calculate d
        ans = elements[16 + index] * t + elements[15 + index]
        ans = ans * t + elements[14 + index]
        ans = ans * Double.pi / 180.0
        circumstances[4] = ans
        
        // sin d and cos d
        circumstances[5] = sin(ans)
        circumstances[6] = cos(ans)
        
        // Calculate dd
        ans = 2.0 * elements[16+index] * t + elements[15 + index]
        ans = ans * Double.pi / 180.0
        circumstances[12] = ans
        
        // Calculate m
        ans = elements[19 + index] * t + elements[18 + index]
        ans = ans * t + elements[17 + index]
        
        if (ans >= 360.0) {
            ans = ans - 360.0
        }
        
        ans = ans * Double.pi / 180.0
        circumstances[7] = ans
        
        // Calculate dm
        ans = 2.0 * elements[19 + index] * t + elements[18 + index]
        ans = ans * Double.pi / 180.0
        circumstances[13] = ans
        
        // Calculate l1 and dl1
        type = circumstances[0]
        if ((type == -2) || (type == 0) || (type == 2)) {
            ans = elements[22 + index] * t + elements[21 + index]
            ans = ans * t + elements[20 + index]
            circumstances[8] = ans
            circumstances[14] = 2.0 * elements[22 + index] * t + elements[21 + index]
        }
        
        // Calculate l2 and dl2
        if ((type == -1) || (type == 0) || (type == 1)) {
            ans = elements[25 + index] * t + elements[24 + index]
            ans = ans * t + elements[23 + index]
            circumstances[9] = ans
            circumstances[15] = 2.0 * elements[25 + index] * t + elements[24 + index]
        }
        
        
        //print("New circumstances from timeDependent: \(circumstances)")
        return circumstances
        
    }
    
    // Populate the circumstances array with the time and location dependent circumstances
    func timeLocDependent(_ circumstances: inout [Double]) -> [Double] {
        //print("timeLocDependent called")
        var index: Int
        var type: Double
        
        timeDependent(&circumstances)
        index = Int(obsvconst[6])
        
        // Calculate h, sin h, cos h
        circumstances[16] = circumstances[7] - obsvconst[1] - (elements[index + 5] / 13713.44)
        circumstances[17] = sin(circumstances[16])
        circumstances[18] = cos(circumstances[16])
        
        // Calculate xi
        circumstances[19] = obsvconst[5] * circumstances[17]
        
        // Calculate eta
        circumstances[20] = obsvconst[4] * circumstances[6] - obsvconst[5] * circumstances[18] * circumstances[5]
        
        // Calculate zeta
        circumstances[21] = obsvconst[4] * circumstances[5] + obsvconst[5] * circumstances[18] * circumstances[6]
        
        // Calculate dxi
        circumstances[22] = circumstances[13] * obsvconst[5] * circumstances[18]
        
        // Calculate deta
        circumstances[23] = circumstances[13] * circumstances[19] * circumstances[5] - circumstances[21] * circumstances[12]
        
        // Calculate u
        circumstances[24] = circumstances[2] - circumstances[19]
        
        // Calculate v
        circumstances[25] = circumstances[3] - circumstances[20]
        
        // Calculate a
        circumstances[26] = circumstances[10] - circumstances[22]
        
        // Calculate b
        circumstances[27] = circumstances[11] - circumstances[23]
        
        // Calculate l1'
        type = circumstances[0]
        if ((type == -2) || (type == 0) || (type == 2)) {
            circumstances[28] = circumstances[8] - circumstances[21] * elements[26 + index]
        }
        
        // Calculate l2'
        if ((type == -1) || (type == 0) || (type == 1)) {
            circumstances[29] = circumstances[9] - circumstances[21] * elements[27 + index]
        }
        // Calculate n^2
        circumstances[30] = circumstances[26] * circumstances[26] + circumstances[27] * circumstances[27]
        
        //print("New circumstances from timeLocDependent: \(circumstances)")
        return circumstances
    }
    
    // Iterate on C1 or C4
    func c1c4Iterate(_ circumstances: inout [Double]) -> [Double] {
        //print("c1c4Iterate called")
        var sign: Double
        var iter: Int
        var tmp: Double
        var n: Double
        
        timeLocDependent(&circumstances)
        if (circumstances[0] < 0) {
            sign = -1.0
        } else {
            sign = 1.0
        }
        
        tmp = 1.0
        iter = 0
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            n = sqrt(circumstances[30])
            tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
            tmp = tmp / n / circumstances[28]
            tmp = sign * sqrt(1.0 - tmp * tmp) * circumstances[28] / n
            tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
            circumstances[1] = circumstances[1] - tmp
            timeLocDependent(&circumstances)
            iter += 1
        }
        
        //print("New circumstances from c1c4Iterate: \(circumstances)")
        return circumstances
        
    }
    
    // Get C1 and C4 data
    //   Entry conditions -
    //   1. The mid array must be populated
    //   2. The magnitude at mid eclipse must be > 0.0
    func getc1c4() {
        //print("getc1c4 called")
        var tmp: Double
        var n: Double
        
        n = sqrt(mid[30])
        tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[28]
        tmp = sqrt(1.0 - tmp * tmp) * mid[28] / n
        c1[0] = -2
        c4[0] = 2
        c1[1] = mid[1] - tmp
        c4[1] = mid[1] + tmp
        
        //print("C1 from getc1c4: \(c1)")
        //print("C4 from getc1c4: \(c4)")
        c1c4Iterate(&c1)
        c1c4Iterate(&c4)
        
    }
    
    // Iterate on C2 or C3
    func c2c3Iterate(_ circumstances: inout [Double]) -> [Double] {
        //print("c2c3Iterate called")
        var sign: Double
        var iter: Int
        var tmp: Double
        var n: Double

        timeLocDependent(&circumstances)
        if (circumstances[0] < 0) {
            sign = -1.0
        } else {
            sign = 1.0
        }
        if (mid[29] < 0.0) {
            sign = -sign
        }
        tmp = 1.0
        iter = 0
        
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            n = sqrt(circumstances[30])
            tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
            tmp = tmp / n / circumstances[29]
            tmp = sign * sqrt(1.0 - tmp * tmp) * circumstances[29] / n
            tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
            circumstances[1] = circumstances[1] - tmp
            
            timeLocDependent(&circumstances)
            iter += 1
        }
        
        
        //print("Circumstances from c2c3Iterate: \(circumstances)")
        return circumstances
    }
    
    // Get C2 and C3 data
    //   Entry conditions -
    //   1. The mid array must be populated
    //   2. There must be either a total or annular eclipse at the location!
    func getc2c3() {
        //print("getc2c3 called")
        var tmp: Double
        var n: Double
        
        n = sqrt(mid[30])
        tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[29]
        tmp = sqrt(1.0 - tmp * tmp) * mid[29] / n
        c2[0] = -1
        c3[0] = 1
        
        if (mid[29] < 0.0) {
            c2[1] = mid[1] + tmp
            c3[1] = mid[1] - tmp
        } else {
            c2[1] = mid[1] - tmp
            c3[1] = mid[1] + tmp
        }
        
        //print("C2 from getc2c3: \(c2)")
        //print("C3 from getc2c3: \(c3)")
        c2c3Iterate(&c2)
        c2c3Iterate(&c3)
        
    }
    
    // Get the observational circumstances
    func observational(_ circumstances: inout [Double]) {
        //print("observational called")
        var contactType: Double
        var cosLat: Double
        var sinLat: Double
        
        // We are looking at an "external" contact UNLESS this is a total eclipse AND we are looking at
        // c2 or c3, in which case it is an INTERNAL contact! Note that if we are looking at mid eclipse,
        // then we may not have determined the type of eclipse (mid[39]) just yet!
        
        if (circumstances[0] == 0) {
            contactType = 1.0
        } else {
            if ((mid[39] == 3) && ((circumstances[0] == -1) || (circumstances[0] == 1))) {
              contactType = -1.0
            } else {
              contactType = 1.0
            }
        }
        
        // Calculate p
        circumstances[31] = atan2(contactType * circumstances[24], contactType * circumstances[25])
                                       
        // Calculate alt
        sinLat = sin(obsvconst[0])
        cosLat = cos(obsvconst[0])
        circumstances[32] = asin(circumstances[5] * sinLat + circumstances[6] * cosLat * circumstances[18])
                                     
        // Calculate q
        circumstances[33] = asin(cosLat * circumstances[17] / cos(circumstances[32]))
        if (circumstances[20] < 0.0) {
            circumstances[33] = Double.pi - circumstances[33]
        }
                                     
        // Calculate v
        circumstances[34] = circumstances[31] - circumstances[33]
                                     
        // Calculate azi
        circumstances[35] = atan2(-1.0 * circumstances[17] * circumstances[6], circumstances[5] * cosLat - circumstances[18] * sinLat * circumstances[6])
                                     
        // Calculate visibility
        if (circumstances[32] > -0.00524) {
            circumstances[40] = 0
        } else {
            circumstances[40] = 1
        }
        
        //print("In observational, Obsvconst: \(obsvconst)")
        //print("New circumstance in observational: \(circumstances)")
        
    }
    
    
    
    // Get the observational circumstances for mid eclipse
    func midobservational() {
        //print("midobservational called")
        observational(&mid)
        
        // Calculate m, magnitude and moon/sun
        mid[36] = sqrt(mid[24] * mid[24] + mid[25] * mid[25])
        mid[37] = (mid[28] - mid[36]) / (mid[28] + mid[29])
        mid[38] = (mid[28] - mid[29]) / (mid[28] + mid[29])
        
        //print("Mid in midobservational: \(mid)")
        
    }
    
    
    // Calculate mid eclipse
    func getmid() {
        //print("getmid called")
        var iter: Int
        var tmp: Double

        mid[0] = 0.0
        mid[1] = 0.0
        iter = 0
        tmp = 1.0
        timeLocDependent(&mid)
      
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            tmp = (mid[24] * mid[26] + mid[25] * mid[27]) / mid[30]
            mid[1] = mid[1] - tmp
            iter += 1
            timeLocDependent(&mid)
        }
        
        //print("In getmid, mid: \(mid)")
        
    }
    
    // Calculate the time of sunrise or sunset
    /*func getsunriset(_ circumstances: inout [Double], riset: Double) {
        //print("getsunriset called")
        var h0: Double
        var diff: Double
        var iter: Int

        diff = 1.0
        iter = 0
        while ((diff > 0.00001) || (diff < -0.00001)) {
            iter += 1
            if (iter == 4) {return}
            h0 = acos((sin(-0.00524) - sin(obsvconst[0]) * circumstances[5]) / cos(obsvconst[0]) / circumstances[6])
            diff = (riset * h0 - circumstances[16]) / circumstances[13]
            while (diff >= 12.0) {diff -= 24.0}
            while (diff <= -12.0) {diff += 24.0}
            circumstances[1] += diff
            timeLocDependent(&circumstances)
        }
        
        
        //print("In getsunriset, circumstance: \(circumstances)")
    }
    
    
    // Calculate the time of sunrise
    func getsunrise(_ circumstances: inout [Double]) {
        //print("getsunrise called")
        getsunriset(&circumstances, riset: -1.0)
        
        
        //print("New circumstance in getSunrise: \(circumstances)")
    }
    
    // Calculate the time of sunset
    func getsunset(_ circumstances: inout [Double]) {
        //print("getsunset called")
        getsunriset(&circumstances, riset: 1.0)
        
        
        //print("New circumstance in getsunset: \(circumstances)")
    }
    
    
    // Copy a set of circumstances
    func copycircumstances(circumstancesfrom: [Double], circumstancesto: [Double]) {
        //print("copycircumstances called")
        var i: Int
        var circumstances1 = circumstancesfrom
        var circumstances2 = circumstancesto

        for i in 1..<41 {
            circumstances2[i] = circumstances1[i]
        }
        
        //print("Circumstance1 in copycircumstances: \(circumstances1)")
        //print("Circumstance2 in copycircumstances: \(circumstances2)")
    }*/
    
    func getall() {
        //print("getall called")
        getmid()
            
        //observational(mid);
        // Calculate m, magnitude and moon/sun
        midobservational()
        
        if (mid[37] > 0.0) {
            getc1c4()
            
            if ((mid[36] < mid[29]) || (mid[36] < -mid[29])) {
                getc2c3()
            
                if (mid[29] < 0.0) {
                    mid[39] = 3 // Total eclipse
                } else {
                    mid[39] = 2 // Annular eclipse
                }
                observational(&c2)
                observational(&c3)
              
                c2[36] = 999.9
                c3[36] = 999.9
            } else {
                mid[39] = 1 // Partial eclipse
            }
            observational(&c1)
            observational(&c4)
        } else {
            mid[39] = 0 // No eclipse
        }
        //print("Mid in getall: \(mid)")
    }

    // Read the data that's in the form, and populate the obsvconst array
    func calcObsv(lat: Double, lon: Double, alt: Double) {
        //print("calcObsv called")
        var tmp: Double
      
        //latitude
        obsvconst[0] = lat * Double.pi / 180.0
      
        //longitude
        obsvconst[1] = lon * Double.pi / 180.0 * -1

        //altitude
        obsvconst[2] = alt

        //timezone is always 0 for these calculations, will convert after
        obsvconst[3] = 0

        // Get the observer's geocentric position
        tmp = atan(0.99664719 * tan(obsvconst[0]))
        obsvconst[4] = 0.99664719 * sin(tmp) + (obsvconst[2] / 6378140.0) * sin(obsvconst[0])
        obsvconst[5] = cos(tmp) + (obsvconst[2] / 6378140.0 * cos(obsvconst[0]))

        //the original code had a list of all besellian elements for a large number of eclipses, but this app currently only needs the elements for the April 8 2024 eclipse, so we set it to 0
        obsvconst[6] = 0
        
        //print("obsvconst in calcObsv: \(obsvconst)")

    }

    // Get the local date of an event
    /*func getdate(_ circumstances: inout [Double]) -> String {
        //print("getdate called")
        var t: Double
        var ans: String
        var jd: Double
        var a: Double
        var b: Double
        var c: Double
        var d: Double
        var e: Double
        var index: Int
        

        index = Int(obsvconst[6])
        
        // Calculate the JD for noon (TDT) the day before the day that contains T0
        jd = floor(elements[index] - (elements[1 + index] / 24.0))
        
        // Calculate the local time (ie the offset in hours since midnight TDT on the day containing T0).
        t = circumstances[1] + elements[1 + index] - obsvconst[3] - (elements[4 + index] - 0.5) / 3600.0
        if (t < 0.0) {
            jd -= 1
        }
        if (t >= 24.0) {
            jd += 1
        }
        if (jd >= 2299160.0) {
            a = floor((jd - 1867216.25) / 36524.25)
            a = jd + 1 + a - floor(a/4)
        } else {
            a = jd
        }
        b = a + 1525.0
        c = floor((b-122.1)/365.25)
        d = floor(365.25 * c)
        e = floor((b - d) / 30.6001)
        d = b - d - floor(30.6001 * e)
        if (e < 13.5) {
            e = e - 1
        } else {
            e = e - 13
        }
        if (e > 2.5) {
            ans = "\(Int(c - 4716))-"
        } else {
            ans = "\(Int(c - 4715))-"
        }
        ans += month[Int(e-1)] + "-"
        if (d < 10) {
            ans += "0"
        }
        ans += "\(d)"
        
        
        //print("In getDate, a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), jd: \(jd), index: \(index), t: \(t)")
        //print("New circumstances in getDate: \(circumstances)")
        //print("Ans in getDate: \(ans)")
        
        return ans
    }*/

    
    // Get the local time of an event
    func gettime(_ circumstances: inout [Double]) -> String {
        //print("gettime called")
        var t: Double
        var ans: String
        var index: Int

        ans = ""
        index = Int(obsvconst[6])
        t = circumstances[1] + elements[1 + index] - obsvconst[3] - (elements[4 + index] - 0.5) / 3600.0
        if (t < 0.0) {
            t = t + 24.0
        }
        if (t >= 24.0) {
            t = t - 24.0
        }
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(Int(floor(t))):"
        t = (t * 60.0) - 60.0 * floor(t)
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(Int(floor(t)))"
        if (circumstances[40] <= 1) { // not sunrise or sunset
            ans += ":"
            t = (t * 60.0) - 60.0 * floor(t)
            if (t < 10.0) {
                ans += "0"
            }
            ans += "\(Int(floor(t)))"
        }
        
        
        //print("In getTime, new circumstances: \(circumstances)")
        
        
        return ans
    }

    //the next five methods aren't currently used but I'm leaving them in because they may be useful later on
    // Get the altitude
    /*func getalt(_ circumstances: inout [Double]) -> String {
        //print("getalt called")
        var t: Double
        var ans: String
        

        if (circumstances[40] == 2) {
            return "0(r)"
        }
        if (circumstances[40] == 3) {
            return "0(s)"
        }
        if ((circumstances[32] < 0.0) && (circumstances[32] >= -0.00524)) {
            // Crude correction for refraction (and for consistency's sake)
            t = 0.0
        } else {
            t = circumstances[32] * 180.0 / Double.pi
        }
        if (t < 0.0) {
            ans = "-"
            t = -t
        } else {
            ans = ""
        }
        t = floor(t + 0.5)
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(t)"
        
        
        //print("In getalt, circumstances: \(circumstances), t: \(t), ans: \(ans)")
        return ans
    }

    
    // Get the azimuth
    func getazi(_ circumstances: inout [Double]) -> String {
        //print("getazi called")
        var t: Double
        var ans: String

        ans = ""
        t = circumstances[35] * 180.0 / Double.pi
        if (t < 0.0) {
            t = t + 360.0
        }
        if (t >= 360.0) {
            t = t - 360.0
        }
        t = floor(t + 0.5)
        if (t < 100.0) {
            ans += "0"
        }
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(t)"
        
        
        //print("In getazi, circumstances: \(circumstances), t: \(t), ans: \(ans)")
        return ans
    }

    //
    // Get the duration in mm:ss.s format
    //
    // Adapted from code written by Stephen McCann - 27/04/2001
    func getduration() -> String {
        //print("getduration called")
        var tmp: Double
        var ans: String
      
        if (c3[40] == 4) {
            tmp = mid[1] - c2[1]
        } else if (c2[40] == 4) {
            tmp = c3[1] - mid[1]
        } else {
            tmp = c3[1] - c2[1]
        }
        if (tmp < 0.0) {
            tmp = tmp + 24.0
        } else if (tmp >= 24.0) {
            tmp = tmp - 24.0
        }
        tmp = (tmp * 60.0) - 60.0 * floor(tmp) + 0.05 / 60.0
        ans = "\(floor(tmp))m"
        tmp = (tmp * 60.0) - 60.0 * floor(tmp)
        if (tmp < 10.0) {
            ans += "0"
        }
        ans += "\(floor(tmp))s"
        
        //print("In getduration, tmp: \(tmp), ans: \(ans)")
        return ans
    }

    //
    // Get the magnitude
    func getmagnitude() -> String {
        //print("getmagnitude called")
        var a: String

        a = String(format: "%.3f", floor(1000.0 * mid[37] + 0.5) / 1000.0)
        //a = Double.toString(floor(1000.0 * mid[37] + 0.5) / 1000.0)

        if (mid[40] == 2) {
            a += "(r)"
        }
        if (mid[40] == 3) {
            a += "(s)"
        }
        //print("In getmagnitude, a: \(a)")
        return a
    }

    //
    // Get the coverage
    func getcoverage() -> String {
        //print("getcoverage called")
        var a: String
        var b: Double
        var c: Double

        if (mid[37] <= 0.0) {
            a = "0.0"
        } else if (mid[37] >= 1.0) {
            a = "1.000"
        } else {
            if (mid[39] == 2) {
                c = mid[38] * mid[38]
            } else {
                c = acos((mid[28] * mid[28] + mid[29] * mid[29] - 2.0 * mid[36] * mid[36]) / (mid[28] * mid[28] - mid[29] * mid[29]))
                b = acos((mid[28] * mid[29] + mid[36] * mid[36]) / mid[36] / (mid[28] + mid[29]))
                a = String(format: "%.3f", Double.pi - b - c)
                //Double.toString(Double.pi - b - c)
                c = ((mid[38] * mid[38] * Double(a)! + b) - mid[38] * sin(c)) / Double.pi
                
            }
            a = String(format: "%.3f", floor(1000.0 * c + 0.5) / 1000.0)
            //Double.toString(floor(1000.0 * c + 0.5) / 1000.0)
        }
        if (mid[40] == 2) {
            a += "(r)"
        }
        if (mid[40] == 3) {
            a += "(s)"
        }
        
        return a
    }*/

    func calculatefor(lat: Double, lon: Double, alt: Double) -> [String] {
        ////print("calculatefor called")
        var info = ["",""]
        
        print("Lat: \(lat), lon: \(lon), alt: \(alt)")
        
        calcObsv(lat: lat, lon: lon, alt: alt)
        //calcObsv(25.122, -104.2252, alt)

        getall()
        print("Eclipse type:", mid[39])
        //print("Mid[39]: \(mid[39])")
        if(mid[39] >= 1){ // added = for testing
            info[0] = gettime(&c2)
            info[1] = gettime(&c3)
            //print("LocationTiming \(info[0]);   \(info[1])")
        }
        else {return ["N/A"]}
        
        //print("Info: \(info)")
        return info
    }
    
}
