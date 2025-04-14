// NOLINTBEGIN(bugprone-exception-escape)
#include <CLI/CLI.hpp>
#include <Foempvge/foempvge_lib.hpp>


// NOLINTNEXTLINE(bugprone-exception-escape)
int main(int argc, const char **argv) {
    INIT_LOG()
    try {
        CLI::App app{FORMAT("{} version {}", Foempvge::cmake::project_name, Foempvge::cmake::project_version)};

        std::optional<std::string> message;
        app.add_option("-m,--message", message, "A message to print back out");
        bool show_version = false;
        app.add_flag("--version", show_version, "Show version information");

        CLI11_PARSE(app, argc, argv);

        if(show_version) {
            LINFO("{}\n", Foempvge::cmake::project_version);
            return EXIT_SUCCESS;
        }
        LINFO("Hello, {}!", message.value_or("World"));
        LINFO("Foempvge version: {}", Foempvge::cmake::project_version);
        VLINFO("Hello, {}!", message.value_or("World"));
        VLINFO("Foempvge version: {}", Foempvge::cmake::project_version);
    } catch(const std::exception &e) { spdlog::error("Unhandled exception in main: {}", e.what()); }
}
