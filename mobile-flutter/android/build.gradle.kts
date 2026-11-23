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
    plugins.withId("com.android.library") {
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        dependencies.add("implementation", "com.google.guava:listenablefuture:9999.0-empty-to-avoid-conflict-with-guava")
    }
    plugins.withId("com.android.application") {
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        dependencies.add("implementation", "com.google.guava:listenablefuture:9999.0-empty-to-avoid-conflict-with-guava")
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
