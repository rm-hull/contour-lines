# Contour Lines UK Pipeline

.PHONY: all clean serve tiles

# Default target: build everything
all: tiles

# 1. Generate list of tile URLs
uk_tiles.txt: uk_tiles.py
	@echo "Generating tile list..."
	python3 uk_tiles.py

# 2. Build virtual mosaic
uk_dem.vrt: uk_tiles.txt
	@echo "Building VRT..."
	gdalbuildvrt -input_file_list uk_tiles.txt uk_dem.vrt

# 3. Generate contour lines (10m)
tmp/contours_uk.gpkg: uk_dem.vrt
	@mkdir -p tmp
	@echo "Generating contours..."
	gdal_contour -a elev -i 10 uk_dem.vrt tmp/contours_uk.gpkg

# 4. Convert to GeoJSON
tmp/contours_uk.geojson: tmp/contours_uk.gpkg
	@echo "Converting to GeoJSON..."
	ogr2ogr -f GeoJSON tmp/contours_uk.geojson tmp/contours_uk.gpkg

# 5. Encode into Vector Tiles
data/mbtiles/contours_uk.mbtiles: tmp/contours_uk.geojson
	@mkdir -p data/mbtiles
	@echo "Running Tippecanoe..."
	tippecanoe \
		--output=$@ \
		--layer=contours \
		--minimum-zoom=6 \
		--maximum-zoom=14 \
		--simplification=2 \
		--drop-densest-as-needed \
		--force \
		$<

# Shortcut to build tiles
tiles: data/mbtiles/contours_uk.mbtiles

# Serve the map
serve:
	@echo "Starting TileServer GL..."
	docker run -p 8080:8080 \
		-v $(shell pwd)/data:/data \
		maptiler/tileserver-gl \
		--config /data/config.json \
		--public_url=http://localhost:8080

# Clean workspace
clean:
	rm -f uk_tiles.txt uk_dem.vrt
	rm -rf tmp/*.gpkg tmp/*.geojson
