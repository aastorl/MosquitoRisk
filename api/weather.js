export default async function handler(req, res) {
  if (req.method !== "GET") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { lat, lon } = req.query || {};
  if (!lat || !lon) {
    return res.status(400).json({ error: "Missing lat/lon query params" });
  }

  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: "OPENWEATHER_API_KEY is not configured" });
  }

  const upstreamUrl =
    `https://api.openweathermap.org/data/2.5/weather` +
    `?lat=${encodeURIComponent(lat)}` +
    `&lon=${encodeURIComponent(lon)}` +
    `&units=metric&appid=${encodeURIComponent(apiKey)}`;

  try {
    const response = await fetch(upstreamUrl);
    const body = await response.text();

    if (!response.ok) {
      return res.status(response.status).send(body);
    }

    res.setHeader("Cache-Control", "s-maxage=300, stale-while-revalidate=600");
    return res.status(200).send(body);
  } catch (error) {
    return res.status(502).json({
      error: "Failed to fetch weather from upstream",
      details: error instanceof Error ? error.message : "Unknown error",
    });
  }
}
