## To do

### Session 2026-03-05:

1. Define calibration areas for models by checking virtual niche suitable areas.
    - Predict suitable areas in geography (North America). Use suitability truncated.
    - Mask prediction with areas of interest (Great Plains and Sierra Madre).
    - Define area for model calibration based on masked prediction so it makes sense geographically.
    - Mask predictions with accessible areas.
    - Generate occurrence points from masked prediction.

2. Prepare data for ENM 
    - Mask raster variables with calibration area.
    - Prepare data for ENM using kuenm2 prepare_data(), see [vignette](https://marlonecobos.github.io/kuenm2/articles/prepare_data.html)
        - Use 4 kfolds for data partitioning.
        - Use other parameter settings included in the script.
    - Prepare additional sets of data with other partitioning methods.
        - Prepare block partitioning.
        - Add prepared blocks into prepared data partitions.
        - Prepare checkerboard partitioning?
        - Add checkerboard into prepared data partitions?

3. Explore prepared data as in the kuenm2 [vignette](https://marlonecobos.github.io/kuenm2/articles/prepare_data.html)
4. Run model calibration for all prepared data sets see [calibration vignette](https://marlonecobos.github.io/kuenm2/articles/model_calibration.html).
    - Make sure the calibration process runs with the argument `remove_concave = FALSE`.

5. Explore training partition effects on response curves as indicated in the previous vignette.
6. Fit and explore selected models ([fit models vignette](https://marlonecobos.github.io/kuenm2/articles/model_exploration.html)) 
    - Fit models selected.
    - Explore response curves.
        - Check single response curves.
        - Explore bivariate responses.
        - Change the range for new data in response curves, so that it includes environments in North America.
    - Evaluate and show variable contribution to models.
    
7. Project fitted models to North America see [vignette](https://marlonecobos.github.io/kuenm2/articles/model_predictions.html).

