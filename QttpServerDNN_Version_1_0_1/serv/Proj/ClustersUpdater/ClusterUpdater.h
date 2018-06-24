#ifndef CLUSTERUPDATER_H
#define CLUSTERUPDATER_H

#include <iostream>
//#include <Parameters.h>
//#include <FeatureDetector.h>
//#include <ClusterCreateator.h>
#include <ClusterPathSender.h>

class ClusterUpdater
{
public:
    ClusterUpdater();
    void run(const std::string & imagePath);
private:
    //void detectParameters(const std::string & imagePath, const std::string & clusterPath);
    //void runFeatureDetector(int countOfThreads);
    //void runClustering();
    void sendPath(const std::string Path);
    std::vector<std::string> readFeatureFromFile(const std::string & path);
private:
   // ParametrsForFeatureDetector m_paramsForFeatureDetector;
   // ParametrsForClustering m_paramsForClustering;

    std::vector<std::string> m_imagesYamlPath;

};

#endif // CLUSTERUPDATER_H
