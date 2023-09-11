load("@rules_oci//oci:defs.bzl", "oci_image", "oci_push", "oci_tarball")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

def oci_push_official(name, image, component):
    oci_push(
        name = name,
        image = image,
        repository = "ghcr.io/buildbarn/" + component,
        tags = ["{BUILD_SCM_TIMESTAMP}-{BUILD_SCM_REVISION}"],
    )

def go_image(name, binary, entrypoint, component):
    pkg_tar(
        name = "%s_app_layer" % name,
        srcs = [binary],
    )

    oci_image(
        name = name,
        entrypoint = entrypoint,
        os = "linux",
        architecture = "amd64",
        tars = ["%s_app_layer" % name],
    )

    oci_tarball(
        name = "%s_tarball" % name,
        image = ":%s" % name,
        repo_tags = ["%s:latest" % component],
    )

    oci_push_official(
        name = "%s_push" % name,
        component = component,
        image = ":%s" % name,
    )
