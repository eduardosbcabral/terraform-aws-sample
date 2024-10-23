FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build
WORKDIR /app

COPY . ./

# Publish application
RUN dotnet publish "Sample.Api/Sample.Api.csproj" \
  -c Release \
  -o /app/publish \
  -r linux-x64 \
  --self-contained true

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy-chiseled
WORKDIR /app
COPY --from=build /app/publish .
COPY --from=build /bin/curl /usr/bin/curl
EXPOSE 5028
ENV ASPNETCORE_HTTP_PORTS=5028
ENTRYPOINT ["./Sample.Api"]