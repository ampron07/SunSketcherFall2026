//
//  Sunset.swift
//  Sunsketcher
//
//  Created by Tameka Ferguson on 10/24/23.
//

/*
 This file was not used in the SunSketcher app release in March 2024 and it was never tested to see if it actually works.
 This was being translated from Java to Swift which was written by Travis Peden. He translated the original source from JS
to Java; Source is https://gml.noaa.gov/grad/solcalc/sunrise.html (Travis has a backup of the JS if site goes down for some reason)
*/

import Foundation


public class Sunset {
    
    public static func calcSun(lat: Double, lon: Double) -> String {
        let timezoneDiff: Int = -Sunset.timeDiff()
        var date: [Int] = Sunset.getDate()
        
        let JD: Int = Sunset.calcJD(date: date)
        
        //daylight saving time boolean, assumed to be true for this test since it's being tested during daylight saving time so doesn't matter. also doesn't matter for actual eclipse because both October 14 and April 8 are in daylight saving time; false would be 0 though
        let daySaving: Int = 60
        
        var newjd: Double = Double(Sunset.findRecentSunset(jd: Double(JD), latitude: lat, longitude: lon))
        var newtime = Sunset.calcSunsetUTC(JD: newjd, latitude: lat, longitude: lon)
        
        if (newtime > 1440) {
            newtime -= 1440
            newjd += 1.0
        }
        if (newtime < 0) {
            newtime += 1440
            newjd -= 1.0
        }
        
        let spd = 60 * 60 * 24
        //let sunset: Int64 = timeUnixMilDate(minutes: newtime, jd: newjd)
        //let currentTime: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
        //let unixSunset: Int64 = (sunset % spd) + (currentTime - (currentTime % spd))

        return Sunset.timeUnixMilDate(minutes: newtime, jd: newjd)
        
    }
    
    static func getDate() -> [Int] {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let now = Date()
        let date = dateFormatter.string(from: now)
        print("Date: \(date)")
        
        let dateComponents = date.split(separator: "/").map { Int($0) }
        
        return dateComponents.compactMap { $0 }
        
    }
    
    static func calcJD(date: [Int]) -> Int {
        var date = date
        if date[1] <= 2 {
            date[0] -= 1
            date[1] += 12
        }
        
        let A: Int = Int(floor(Double(date[0]/100)))
        let B: Int = 2 - A + Int(floor(Double(A/4)))
        
        let JD = Int(floor(365.25 * (Double(date[0] + 4716)) + floor(30.6001 * (Double(date[1] + 1)) + Double(date[2]) + Double(B) - 1524.5)))
        
        return JD
    }
    
    static func calcTimeJulianCent(jd: Double) -> Double {
        return (jd - 2451545.0) / 36525.0
    }
    
    static func calcObliquityCorrection(t: Double) -> Double {
        let e0: Double = calcMeanObliquityOfEcliptic(t: t)
        
        let omega: Double = 125.04 - 1934.136 * t
        return e0 + 0.00256 * cos((Double.pi / 180) * omega)
        
    }
    
    static func calcMeanObliquityOfEcliptic(t: Double) -> Double {
        let seconds: Double = 21.448 - t * (46.8150 + t * (0.00059 - t * (0.001813)))
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0
    }
    
    static func calcSunApparentLong(t: Double) -> Double {
        let o: Double = calcSunTrueLong(t: t)
        let omega: Double = 125.04 - 1934.136 * t
        return o - 0.00569 - 0.00478 * sin((Double.pi / 180) * omega)
    }
    
    static func calcSunTrueLong(t: Double) -> Double {
        let l0: Double = calcGeomMeanLongSun(t: t)
        let c: Double = calcSunEqOfCenter(t: t)
        return l0 + c
        
    }
    
    static func calcGeomMeanLongSun(t: Double) -> Double {
        var l0: Double = 280.46646 + t * (36000.76983 + 0.0003032 * t)
        while (l0 > 360.0) {
            l0 -= 360.0
        }
        while(l0 < 0.0){
            l0 += 360.0
        }
        return l0
    }
    
    static func calcSunEqOfCenter(t: Double) -> Double {
        let m: Double =  calcGeomMeanAnomalySun(t: t)
        let mrad: Double = m * (Double.pi / 180)
        let sinm: Double = sin(mrad)
        let sin2m: Double = sin(mrad * 2)
        let sin3m: Double = sin(mrad * 3)
        return sinm * (1.914602 - t * (0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289
    }
    
    static func calcGeomMeanAnomalySun(t: Double) -> Double {
        return 357.52911 + t * (35999.05029 - 0.0001537 * t)
    }
    
    static func calcSunDeclination(t: Double) -> Double {
        let e: Double = calcObliquityCorrection(t: t)
        let lambda: Double = calcSunApparentLong(t: t)
        let sint: Double = sin((Double.pi / 180) * e) * sin((Double.pi / 180) * lambda)
        return asin(sint) * 180 / .pi // 180 / .pi is equivalent to java's Math.degrees
    }
    
    static func calcEquationOfTime(t: Double) -> Double {
        let epsilon: Double = calcObliquityCorrection(t: t)
        let l0: Double = calcGeomMeanLongSun(t: t)
        let e: Double = calcEccentricityEarthOrbit(t: t)
        let m: Double = calcGeomMeanAnomalySun(t: t)
        
        var y: Double = tan((epsilon * .pi / 180) / 2.0) // .pi / 180 multiplied with the number changes it from degrees to radians
        y *= y;
        
        let sin2l0: Double = sin(2.0 * (10 * .pi / 180))
        let sinm: Double = sin(m * .pi / 180)
        let cos2l0: Double = cos(2.0 * (10 * .pi / 180))
        let sin4l0: Double = sin(4.0 * (10 * .pi / 180))
        let sin2m: Double = sin(2.0 * (m * .pi / 180))
        
        return (y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m) * 4.0 * 180 / .pi
    }

    static func calcEccentricityEarthOrbit(t: Double) -> Double {
        return 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
    }
    
    static func calcSolNoonUTC(t: Double, longitude: Double) -> Double {
        let tnoon: Double = calcTimeJulianCent(jd: (calcJDFromJulianCent(t: t) + longitude / 360.0))
        var eqTime: Double = calcEquationOfTime(t: tnoon)
        var solNoonUTC: Double = 720 + (longitude * 4) - eqTime
        
        let newt: Double = calcTimeJulianCent(jd: (calcJDFromJulianCent(t: t) - 0.5 + solNoonUTC / 1440.0))
        
        eqTime = calcEquationOfTime(t: newt)
        solNoonUTC = 720 + (longitude * 4) - eqTime
        
        return solNoonUTC
    }
    
    static func calcJDFromJulianCent(t: Double) -> Double {
        return t * 36525.0 + 2451545.0
    }
    
    static func calcSunsetUTC(JD: Double, latitude: Double, longitude: Double) -> Double {
        let t: Double = calcTimeJulianCent(jd: JD)
        
        let noonmin: Double = calcSolNoonUTC(t: t, longitude: longitude)
        let tnoon: Double = calcTimeJulianCent(jd: (JD + noonmin / 1440.0))
        
        var eqTime: Double = calcEquationOfTime(t: tnoon)
        var solarDec: Double = calcSunDeclination(t: tnoon)
        var hourAngle: Double = calcHourAngleSunset(lat: latitude, solarDec: solarDec)
        
        var delta: Double = longitude - (hourAngle * .pi / 180)
        var timeDiff: Double = 4 * delta
        var timeUTC: Double = 720 + timeDiff - eqTime
        
        let newt: Double = calcTimeJulianCent(jd: (calcJDFromJulianCent(t: t) + timeUTC / 1440.0))
        eqTime = calcEquationOfTime(t: newt)
        solarDec = calcSunDeclination(t: newt)
        hourAngle = calcHourAngleSunset(lat: latitude, solarDec: solarDec)
        
        delta = longitude - (hourAngle * 180 / .pi)
        timeDiff = 4 * delta
        timeUTC = 720 + timeDiff - eqTime
        
        return timeUTC
    }
    
    static func calcHourAngleSunset(lat: Double, solarDec: Double) -> Double {
        let latRad: Double = lat * .pi / 180
        let sdRad: Double = solarDec * .pi / 180
        
        var HA: Double = (acos(cos(90.833 * .pi / 180) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)))
        
        return -HA
    }
    
    static func findRecentSunset(jd: Double, latitude: Double, longitude: Double) -> Double {
        let julianday: Double = jd
        return julianday
    }
    
    static func timeUnixMilDate(minutes: Double, jd: Double) -> String {
        let floatHour: Double = minutes / 60.0
        var hour: Int = Int(floor(Double(floatHour)))
        let floatMinute: Double = 60.0 * (floatHour - Double(hour))
        var minute: Int = Int(floor(Double(floatMinute)))
        let floatSec: Double = 60.0 * (floatMinute - Double(minute))
        var second: Int = Int(floor(Double(floatSec + 0.5)))
        
        //let timeUnix: Int64 = convertTimes(start: [hour, minute, second])
        hour = convertHour(hour: hour)
        
        var secondStr: String
        var minuteStr: String
        var hourStr: String
        
        if(second < 10){
            secondStr = "0" + String(second)
        } else if(second == 60){
            second = 0
            minute += 1
            secondStr = "00"
        } else {
            secondStr = "" + String(second)
        }
        
        if(minute < 10){
            minuteStr = "0" + String(minute)
        } else {
            minuteStr = "" + String(minute)
        }
        
        hourStr = "" + String(hour)
        
        var timeString: String = hourStr + ":" + minuteStr + ":" + secondStr
        
        
        return timeString
    }
    
    static func convertHour(hour: Int) -> Int {
        var timeDiff: Int = 0
        let timeZone = TimeZone.current
        
        
        switch timeZone.abbreviation(){
        case "HST":
            timeDiff = -10
        case "AKDT":
            timeDiff = -8
        case "PDT":
            timeDiff = -7
        case "MDT":
            timeDiff = -6
        case "CDT":
            timeDiff = -5
        case "EDT":
            timeDiff = 4
        default:
            timeDiff = -3
        }
        
        return hour + timeDiff
    }
    
    //the calcSun function uses CDT as its base timezone, so we need to separately determine the difference in hours between CDT and the user's timezone
    static func convertTimes(start: [Double]) -> Int32 {
        
        //we don't need to worry about standard timezones, since the actual eclipse is on 4/8, during daylight savings
        var timeDiff: Int = 0
        let timeZone = TimeZone.current
        
        switch timeZone.abbreviation() {
        case "HST":
            timeDiff = -6
        case "AKDT":
            timeDiff = -4
        case "PDT":
            timeDiff = -3
        case "MDT":
            timeDiff = -2
        case "CDT":
            timeDiff = -1
        case "EDT":
            timeDiff = 0
        default:
            timeDiff = -1
        }
        
        //get current unix time, mod to get current unix date, add calculated time as unix time to get unix time of sunset
        let current = Int32(Date().timeIntervalSince1970)
        let timeUnix = (current - (current % (60 * 60 * 24))) + (Int32(start[0]) + Int32(timeDiff)) * 3600 + Int32(start[1]) * 60 + Int32(start[2])
        
        return timeUnix
    }
    
    static func timeDiff() -> Int {
        var hours: Int
        let timeZone = TimeZone.current
        
        switch timeZone.abbreviation(){
        case "HST":
            hours = -10
        case "AKDT":
            hours = -8
        case "PDT":
            hours = -7
        case "MDT":
            hours = -6
        case "CDT":
            hours = -5
        case "EDT":
            hours = -4
        default:
            hours = -3
        }
        return hours
    }
    
    
}
