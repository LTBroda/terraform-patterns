class BigQueryProviderError(Exception):
    """Base exception for BigQueryProvider errors."""


class MissingEnvironmentVariableError(Exception):
    """Raised when required environment variables are missing."""
