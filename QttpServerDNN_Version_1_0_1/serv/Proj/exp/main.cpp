#include <QCoreApplication>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
int main(int argc, char *argv[])
{
    cv::FileStorage fs("/root/.info/parameters.yaml",cv::FileStorage::WRITE);
    fs<<"fdImagesPath"<<"/root/trainDataImages/";
    fs<<"fdDetectorNames"<<"Orb";//toCheck
    fs<<"fdFeatureCount"<<400;
    fs<<"ccType"<<0;
    fs<<"ccImagesPath"<<"/root/trainDataImages/";
    fs<<"ccDeltaForAngle"<< 5;
    fs<<"ccDeltaForKptsAngle"<<1000;
    fs<<"ccClusterPath"<<"/root/defaultCluster/";
    fs<<"otNames"<<"Orb400";


    return 0;
}
