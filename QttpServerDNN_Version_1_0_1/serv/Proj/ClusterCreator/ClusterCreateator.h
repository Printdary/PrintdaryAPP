#ifndef CLUSTERCREATOR_H
#define CLUSTERCREATOR_H

#include "Clustering.h"
#include "Parameters.h"
#include "ClusteringWithAngles.h"

class ClusterCreator
{
public:
    ClusterCreator(const ParametrsForClustering &Params);
private:
    Clustering *detectClusterCreatorType(const clusterCreatorType &type,cv::String Path);
    bool createClusters(const ParametrsForClustering &Params);
    bool isFormatYaml(std::string Path);
    void infoAboutThis(ParametrsForClustering Params);
    bool isRightFile(std::string path , std::string extractorName);
private:
    Clustering *m_clusterCreator;
};

#endif // CLUSTERCREATOR_H
