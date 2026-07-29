import axios, { AxiosError } from "axios";

const BASE_URL = "/api";

class ApiError extends Error {
  constructor(
    public status: number,
    message: string
  ) {
    super(message);
    this.name = "ApiError";
  }
}

const axiosInstance = axios.create({
  baseURL: BASE_URL,
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});

function handleError(error: unknown): never {
  if (error instanceof AxiosError) {
    throw new ApiError(
      error.response?.status || 500,
      error.response?.data?.error?.message || error.message || "An unexpected error occurred"
    );
  }
  throw new ApiError(500, "An unexpected error occurred");
}

export const api = {
  get: async <T = Record<string, unknown>>(endpoint: string): Promise<T> => {
    try {
      const response = await axiosInstance.get<T>(endpoint);
      return response.data;
    } catch (error) {
      handleError(error);
    }
  },

  post: async <T = Record<string, unknown>>(
    endpoint: string,
    body?: unknown
  ): Promise<T> => {
    try {
      const response = await axiosInstance.post<T>(endpoint, body);
      return response.data;
    } catch (error) {
      handleError(error);
    }
  },

  patch: async <T = Record<string, unknown>>(
    endpoint: string,
    body?: unknown
  ): Promise<T> => {
    try {
      const response = await axiosInstance.patch<T>(endpoint, body);
      return response.data;
    } catch (error) {
      handleError(error);
    }
  },

  delete: async <T = Record<string, unknown>>(endpoint: string): Promise<T> => {
    try {
      const response = await axiosInstance.delete<T>(endpoint);
      return response.data;
    } catch (error) {
      handleError(error);
    }
  },
};
