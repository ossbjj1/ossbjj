#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // Enable Per-Monitor DPI awareness for HiDPI support (Windows 10+)
  // Prefers Per-Monitor V2 if available, falls back to V1 or legacy awareness.
  typedef BOOL(WINAPI * SetProcessDpiAwarenessContextProc)(DPI_AWARENESS_CONTEXT);
  auto set_process_dpi_awareness_context =
      reinterpret_cast<SetProcessDpiAwarenessContextProc>(
          GetProcAddress(GetModuleHandle(L"user32.dll"),
                         "SetProcessDpiAwarenessContext"));
  if (set_process_dpi_awareness_context) {
    set_process_dpi_awareness_context(
        DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  } else {
    // Fallback for older Windows versions
    typedef HRESULT(WINAPI * SetProcessDpiAwarenessProc)(int);
    auto set_process_dpi_awareness =
        reinterpret_cast<SetProcessDpiAwarenessProc>(
            GetProcAddress(GetModuleHandle(L"shcore.dll"),
                           "SetProcessDpiAwareness"));
    if (set_process_dpi_awareness) {
      set_process_dpi_awareness(2); // PROCESS_PER_MONITOR_DPI_AWARE
    }
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"oss", origin, size)) {
    ::CoUninitialize();
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
