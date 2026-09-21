allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force all Android plugins to compile against SDK 35
// so they are compatible with modern AndroidX dependencies.
gradle.projectsEvaluated {
    subprojects {
        extensions.findByName("android")?.let { ext ->
            try {
                (ext as com.android.build.gradle.BaseExtension).compileSdkVersion(36)
            } catch (_: Throwable) {}
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

