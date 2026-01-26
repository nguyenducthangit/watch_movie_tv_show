import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.watch.movie.tv.show.dev"
            resValue(type = "string", name = "app_name", value = "(Dev) InspireFlix")
//            resValue(type = "string", name = "ads_app_id", value = "ca-app-pub-3940256099942544~3347511713")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.watch.movie.inspireflix"
            resValue(type = "string", name = "app_name", value = "InspireFlix")
//            resValue(type = "string", name = "ads_app_id", value = "ca-app-pub-3940256099942544~3347511713")
        }
    }
}