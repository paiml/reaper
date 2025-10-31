//! Build script for Ruchy project
//!
//! Automatically transpiles .ruchy files to .rs files during cargo build

fn main() {
    // Transpile all .ruchy files in src/ to .rs files
    ruchy::build_transpiler::transpile_all("src", "**/*.ruchy", "src")
        .expect("Failed to transpile Ruchy files");

    // Tell Cargo to re-run this build script if any .ruchy files change
    println!("cargo:rerun-if-changed=src");
}
