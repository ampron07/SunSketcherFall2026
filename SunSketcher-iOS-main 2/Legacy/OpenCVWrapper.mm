//
//  OpenCVWrapper.mm
//  Sunsketcher
//
//  Created by Kelly Miller on 2/23/24.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs.hpp>
#import <opencv2/core/mat.hpp>
#import <opencv2/core/utils/filesystem.hpp>
#import <opencv2/core/matx.hpp>
#import "OpenCVWrapper.h"

// #include <array>
// using namespace cv;


// converts a UIImage to a Mat
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat : (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat : (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

// turns a given image grayscale
+ (UIImage *)makeUIImageGrayScale:(UIImage *)image {
    cv::Mat mat;
    
    // convert the UIImage to an OpenCV Mat for processing
    [image convertToMat: &mat :false];
    
    cv::Mat matGray;
    
    NSLog(@"channels = %d", mat.channels());

    // check if it is already grayscale, and if not, change to grayscale
    if (mat.channels() > 1) {
        cv::cvtColor(mat, matGray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(matGray);
    }

    // convert the mat back to UIImage
    UIImage *grayImg = MatToUIImage(matGray);
    return grayImg;
}


cv::Mat makeMatGrayScale(cv::Mat &img) {
    cv::Mat imgGrey;
    cv::cvtColor(img, imgGrey, cv::COLOR_BGR2GRAY);
    return imgGrey;
}

cv::Rect convertCoordsToRect(NSArray<NSNumber *> * boxCoords) {
    
    double startX = [boxCoords[0] doubleValue];
    double startY = [boxCoords[1] doubleValue];
    double endX = [boxCoords[2] doubleValue];
    double endY = [boxCoords[3] doubleValue];
    
    return cv::Rect(cv::Point(startX, startY), cv::Point(endX, endY));
}

NSArray<NSNumber *> *convertRectToCoords(cv::Rect cropBox) {
    double startX = cropBox.x;
    double startY = cropBox.y;
    double side = cropBox.width;
    
    double endX = startX + side;
    double endY = startY + side;
    
    double coords[] = {startX, startY, endX, endY};
    
    // Create an NSMutableArray to hold NSNumber objects
    NSMutableArray<NSNumber *> *numberArray = [NSMutableArray array];

    // Iterate over the double values and add them to the numberArray
    for (int i = 0; i < sizeof(coords) / sizeof(coords[0]); i++) {
        NSNumber *number = [NSNumber numberWithDouble:coords[i]];
        [numberArray addObject:number];
    }

    // Convert the NSMutableArray to NSArray
    NSArray<NSNumber *> *boxCoords = [numberArray copy];
    
    return boxCoords;
}

// find the brightest spot in the image and create the box around it, represented as array with coords
+ (NSArray<NSNumber *> *)getEclipseBox:(UIImage *)img {
    cv::Mat imgMat;
    
    // convert UIImage to mat
    [img convertToMat: &imgMat :false];
    
    // Make image grayscale
    cv::Mat imgGrey = makeMatGrayScale(imgMat);
    
    // Apply Gaussian blur to reduce noise
    cv::GaussianBlur(imgGrey, imgGrey, cv::Size(5, 5), 0);
    
    // Find brightest spot using minMaxLoc
    cv::Point maxLoc;
    double minValue, maxValue;
    cv::minMaxLoc(imgGrey, &minValue, &maxValue, nullptr, &maxLoc);
    int maxLocX = maxLoc.x;
    int maxLocY = maxLoc.y;
    std::cout << "Max Location - X: " << maxLocX << " Y: " << maxLocY << std::endl;
    
    // Get the image's dimensions based on mat rows and columns
    int imgMaxX = imgMat.rows;
    int imgMaxY = imgMat.cols;
    
    // Side length of box relative to image size, ~2% of original image size
    double side = sqrt((imgMaxX * imgMaxY)) * 0.02;
    
    // Create the coords for rectangle and check if starting/ending coordinates for rectangle are out of image bounds
    cv::Point startCoord = boundaryCheck(cv::Point(maxLocX - side, maxLocY - side), imgMaxX, imgMaxY);
    cv::Point endCoord = boundaryCheck(cv::Point(maxLocX + side, maxLocY + side), imgMaxX, imgMaxY);
    
    // Create the region of interest (ROI) rectangle around brightest spot
    cv::Rect roi(startCoord, endCoord);
    
    // Create the actual crop box to be used on all of the user's images
    cv::Point boxStartCoord = boundaryCheck(cv::Point(roi.x - roi.width, roi.y - roi.width), imgMaxX, imgMaxY);
    cv::Point boxEndCoord = boundaryCheck(cv::Point(roi.x + 2 * roi.width, roi.y + 2 * roi.width), imgMaxX, imgMaxY);
    
    // convert mat back to UIImage
    MatToUIImage(imgMat);
    
    NSLog(@"%f", boxStartCoord.x);
    NSLog(@"%f", boxStartCoord.y);
    NSLog(@"%f", boxEndCoord.x);
    NSLog(@"%f", boxEndCoord.y);
    
    return convertRectToCoords(cv::Rect(boxStartCoord, boxEndCoord));
}


// checks if given point is within the given image boundaries
cv::Point boundaryCheck(cv::Point pt, int maxX, int maxY) {
    if (pt.x < 0) {
        pt.x = 0.0;
    }
    if (pt.x > maxX) {
        pt.x = maxX;
    }
    if (pt.y < 0) {
        pt.y = 0.0;
    }
    if (pt.y > maxY) {
        pt.y = maxY;
    }
    return pt;

}

+ (UIImage *)croppingUIImage:(UIImage *)image withCoords:(NSArray<NSNumber *> *)boxCoords {
    cv::Mat imgMat;
    
    cv::Rect cropBox = convertCoordsToRect(boxCoords);
    
    // convert the UIImage to an OpenCV Mat for processing
    [image convertToMat: &imgMat :false];
    
    // crop the mat
    cv::Mat imgMatCropped = imgMat(cropBox);
    
    return MatToUIImage(imgMatCropped);
}


@end
