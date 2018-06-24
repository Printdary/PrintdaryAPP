#ifndef __NATIVE_HANDLE_H__
#define __NATIVE_HANDLE_H__

#include "base.h"
#include "callback.h"

#ifdef SSL_TLS_UV
    #include <evt_tls.h>
#endif

namespace native
{
namespace base
{
class handle;

void _delete_handle(uv_handle_t* h);

class handle
{
  public:
    template<typename T>
    handle(T* x)
      : uv_handle_(reinterpret_cast<uv_handle_t*>(x))
    {
      PRINT_DBG("Memory address of handle: " << std::hex << this);
      assert(uv_handle_);

      uv_handle_->data = new callbacks(native::internal::uv_cid_max);
      assert(uv_handle_->data);
    }

    virtual ~handle()
    {
      PRINT_DBG("Memory address of handle: " << std::hex << this);
      uv_handle_ = nullptr;
    }

    handle(const handle& h)
      : uv_handle_(h.uv_handle_)
    {
      PRINT_DBG("Memory address of handle: " << std::hex << this);
    }

  public:
    template<typename T = uv_handle_t>
    T* get() {
      return reinterpret_cast<T*>(uv_handle_);
    }

    template<typename T = uv_handle_t>
    const T* get() const {
      return reinterpret_cast<T*>(uv_handle_);
    }

    bool is_active() {
      return uv_is_active(get()) != 0;
    }

    void close(std::function<void()> callback);

    handle& operator =(const handle& h)
    {
      uv_handle_ = h.uv_handle_;
      return *this;
    }

  protected:
    uv_handle_t* uv_handle_;
};
}
}

#endif
