lats = range(49, 62)
lons = range(-9, 3)

urls = []
for lat in lats:
    for lon in lons:
        ns = f"N{lat:02d}"
        ew = f"W{abs(lon):03d}" if lon < 0 else f"E{lon:03d}"
        path = f"Copernicus_DSM_COG_10_{ns}_00_{ew}_00_DEM"
        url = f"/vsicurl/https://copernicus-dem-30m.s3.amazonaws.com/{path}/{path}.tif"
        urls.append(url)

with open("uk_tiles.txt", "w") as f:
    f.write("\n".join(urls))