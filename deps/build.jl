using BinaryProvider
using CxxWrap # this is needed for opening the dependency lib. Otherwise Libdl.dlopen fails

##################### LCIO ###########################
# We are trying to find the right version of LCIO. By default, don't set anything and the right version will just be downloaded. However, for debugging purposes, we'd might want to use the pre-installed lib
const lcioversion = "02-12-01"
const LCIO_DIR = get(ENV, "LCIO_DIR", "")
const verbose = "--verbose" in ARGS
const lcioprefix = Prefix(LCIO_DIR == "" ? get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")) : LCIO_DIR)

# The products that we will ensure are always built
lcioproducts = [
    LibraryProduct(lcioprefix, "liblcio", :liblcio),
    LibraryProduct(lcioprefix, "libsio", :libsio)
]

const lcio_bin_prefix = "https://github.com/jstrube/LCIOBuilder/releases/download/v2.00.01"
# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:x86_64, :glibc) => ("$lcio_bin_prefix/LCIOBuilder.v2.12.1.x86_64-linux-gnu.tar.gz", "f76d8f20510698c291e8b8417447d4399a9f324bafb0e4406c0ef3420158b481"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in lcioproducts)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=lcioprefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=lcioprefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

######################################################

################### LCIO Wrapper #####################
const wrapprefix = Prefix(joinpath(@__DIR__, "usr"))

# Download binaries from hosted location
const wrap_bin_prefix = "https://github.com/jstrube/LCIOWrapBuilder/releases/download/untagged-6febbc8733a82f21b23c/"
download_info = Dict(
        Linux(:x86_64, :glibc) => ("$wrap_bin_prefix/LCIOWrapBuilder.v0.99.0.x86_64-linux-gnu.tar.gz",     "7c04ebf034323b197233f6792546b114880726f40a904c11cc683c85e24458bc"),
    )

# The products that we will ensure are always built
wrapproducts = [
    LibraryProduct(wrapprefix, "liblciowrap", :liblciowrap)
]

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in wrapproducts)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=wrapprefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=wrapprefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end
######################################################
write_deps_file(joinpath(@__DIR__, "deps.jl"), [lcioproducts; wrapproducts])
