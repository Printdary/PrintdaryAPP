#ifndef QTTP_DEFAULTS_H
#define QTTP_DEFAULTS_H

#include "qttp_global.h"
#include "action.h"

namespace qttp
{

class QTTPSHARED_EXPORT OptionsPreprocessor : public Processor
{
  public:
    OptionsPreprocessor();
    const char* getName() const;
    void preprocess(HttpData& data);
};

// TODO: WE NEED TO INCLUDE A DEFAULT ENDPOINT FOR DATA STATS.

}
#endif // QTTP_DEFAULTS_H
