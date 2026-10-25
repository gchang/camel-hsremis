# Changes from the LP DAAC package

Source: the CAMEL V003 climatology HSR emissivity Fortran library, `MEASURES_CAMEL_CLIMAT_hsremis_lib_snowCorr_V003`, Version V3.0 (v03r05), readme dated March 2024. There is no public git repository; LP DAAC links the source tarball from the CAM5K30CFCLIM and CAM5K30EMCLIM V003 product pages:

- https://lpdaac.usgs.gov/documents/2234/FORTRAN_Source_Code.tar.gz
- 384,329,261 bytes, downloaded 2026-10-25
- sha256 `0b9543425a75742a2d194497e8f83ce3c498c6bcc4761a05947e08c50a587a12`, md5 `63e4f072d6836184218107af89a37a59`
- The readme also names a mirror at bin.ssec.wisc.edu (not used here).

Author: Eva Borbas, UW-Madison SSEC/CIMSS (eva.borbas@ssec.wisc.edu), under the NASA MEaSUREs project Unified and Coherent Land Surface Temperature and Emissivity ESDR. The tarball has no license file, and this copy adds none.

This copy starts from the tarball's file tree, with the contents of its single top folder at the root, and no other history. The files are unchanged except for the items below. The library's arithmetic, the lab coefficient files (`coef/`), the test program's inputs and the expected outputs are untouched.

## Left out

- `data/` (384 MB): `CAMEL_coef_climatology_01Month_V003.nc` (196,044,058 bytes, md5 `259a5b7bca9540b1ef7dcbc51ee9bb07`), `CAMEL_emis_climatology_01Month_V003.nc` (44,974,191 bytes, md5 `ecdb06b6398ddbf9e55cf58cb9f0b297`) and `CAMEL_emis_uncertainty_climatology_01Month_V003.nc` (142,570,965 bytes, md5 `a1c9abc41bc55b4af5b0db622b5a8e5b`). The test reads only the first. The first two are byte-identical to the LP DAAC CAM5K30CFCLIM and CAM5K30EMCLIM V003 January granules; the third is the CAM5K30UCCLIM January granule by name (not compared). Get them from the tarball above, or from LP DAAC with an Earthdata login, for example https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/CAM5K30CFCLIM.003/CAM5K30CFCLIM_coef_climatology_01Month_V003/CAM5K30CFCLIM_coef_climatology_01Month_V003.nc saved as `data/CAMEL_coef_climatology_01Month_V003.nc`. The readme says this in install step 3.

## 2026-10-25: empty `lib/`, `include/` and `data/` folders kept

`make -f Makefile_lib install` moves the library into `../lib/` and the include file into `../include/`, and the test reads `../data/`. Git does not keep empty folders, so each has an empty `.gitkeep`.

## 2026-10-25: folder paths of any length

The lab PC file name was built in a 200-character buffer (`read_labpcs.f`), and the folder arguments and the coefficient file name were fixed at 300 characters (`hsriremis_clim_EDR.inc`). A `lab_dir` longer than about 186 characters, or a `camel_dir` longer than about 262, was cut off. The file was then "not found", the library printed a message and returned, and the run wrote emissivity 0.0 at every wavelength with exit status 0.

`path_camel` and `path_lab` are now `character(len=*)` in `compute_clim_hsriremis`, `init_hsriremis` and `read_labpcs`, so they take whatever length the caller declares (including a quoted string), and they are no longer declared in the include file. `fn_coef` and the lab file name buffer are 4096 characters (the Linux PATH_MAX), and so are `camel_dir` and `lab_dir` in the test program. A caller that used the include file's `path_camel` or `path_lab` as its own variables must now declare them itself.

Results do not change for paths that already worked.

## 2026-10-25: `environment.yml` for conda-forge builds

The makefiles take the netCDF folders from `SSEC_NETCDF4_INC` and `SSEC_NETCDF4_LIB`, which `module load gcc hdf hdf5 netcdf4` sets on the SSEC computers. `environment.yml` lists gfortran, netcdf-fortran and make from conda-forge; its comments give the make lines with both variables set to `$CONDA_PREFIX` (plus `LINK_FLAGS=-Wl,-rpath,$CONDA_PREFIX/lib` for the test program), so neither makefile needs editing. One readme line points to it.

## Known issues, not changed

These either change results or are how the package is meant to be used, so they are left as they are. Line numbers are in this copy; the first three are two lines lower than in the tarball.

- **Wavenumber type.** `compute_clim_hsriremis.f:102` declares `instr_wn` as `Real*8`, but `select_wavenum.f:30` takes it as `Real`. The test program passes `REAL`, which works. A caller who follows the `Real*8` declaration gets a flat, wrong spectrum (the Namib desert came back as 0.9748 at all 13 CAMEL wavelengths instead of 0.73 to 0.98). Pass the wavenumbers as `REAL`.
- **Water pixels.** For water `coef_lut` is -1, and `compute_clim_hsriremis.f:166,175,248` then index `weights(:, -1)` and `pcacoefs(:, -1)`. The result is emissivity 0.0, not a fill value. Callers should pass land pixels only (the coefficient file's `landflag`).
- **Snow fraction range check.** `compute_clim_hsriremis.f:133` tests `snowfrac > 1. .and. snowfrac < 0.`, which is never true, so an out-of-range snow fraction is not caught. Keep it in [0, 1].
- **Inputs set by editing the test program.** Month, data paths, site, snow flag and snow fraction are assignments in `test/run_hsriremis.f:65-88`, the IASI channel list is read from `iasi_chans616.txt` in the current folder, and outputs go to the current folder. This is a library with an example program, not a command-line tool.
- **Missing files are not fatal.** A missing lab PC file (`read_labpcs.f:57-61`) or coefficient file (`compute_clim_hsriremis.f:121-125`) prints a message and returns, so a wrong path still gives all-zero output with exit status 0. Check the log for "not found".
- **Memory.** `hsriremis_clim_EDR.inc` sizes static arrays for half the global grid, so every run reads the whole coefficient file and peaks at about 4.75 GiB, even for one pixel. It needs `-mcmodel=large` (already in the makefiles).
- **Climatology only.** The library reads the climatology coefficients (CAM5K30CFCLIM). The monthly CAM5K30CF files have a different layout and need the MATLAB code from LP DAAC.

## Check

On 2026-10-25 (Linux x86_64), in a fresh conda environment: a local `git clone` of this repository, `conda env update -f environment.yml` (gfortran 16.2.0, netcdf-fortran 4.6.4, libnetcdf 4.10.1, make 4.4.1), the January coefficient file copied into `data/`, then the make lines from `environment.yml`. Both builds gave no warnings or errors.

- `cd test; ./run_hsriremis.exe` (NorthMadW, shipped `../data/` and `../coef/` paths): exit 0, 10 s, 4.75 GiB peak. `NorthMadW_hsremis.txt` and `NorthMadW_iasi_emis.txt` are byte-identical to the copies shipped in `test/` and in `test/save_results/`.
- The same test with `camel_dir` and `lab_dir` set to folders whose paths are 250 and 600 characters long: byte-identical output. Before the path fix, the 250-character run printed "Lab PC file not found" five times and wrote 0.0 everywhere, with exit 0.
- All 89,312 land pixels of 5-20 N, 5-20 E through the library (January, no snow correction): 22 s, 4.75 GiB peak. The comparison with the CAM5K30EMCLIM January emissivity at the 13 CAMEL wavelengths is the same as before the changes (r 0.9989, bias +0.0003, RMSE 0.0031 over all wavelengths).

The version is the static `prd_version = 'v03r05'` in `hsriremis_clim_EDR.inc` (readme: V3.0); git tags do not change the build. This copy is tagged `v3.0.post1`.
