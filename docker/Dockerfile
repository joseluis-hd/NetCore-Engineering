# Stage 1: Compilacion
FROM rust:1.93-slim-bookworm AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar manifiestos para cachear dependencias
COPY rust/Cargo.toml rust/Cargo.lock ./

# Crear estructura dummy para compilar dependencias
RUN mkdir -p src/bin src/common && \
    echo 'fn main() { println!("dummy"); }' > src/main.rs && \
    echo 'fn main() { println!("dummy"); }' > src/bin/coordinator.rs && \
    echo 'fn main() { println!("dummy"); }' > src/bin/worker.rs && \
    echo 'pub mod messages; pub mod mandelbrot;' > src/common/mod.rs && \
    echo 'use serde::{Deserialize, Serialize}; #[derive(Serialize, Deserialize)] pub struct Dummy { pub x: i32 }' > src/common/messages.rs && \
    echo 'pub fn dummy() -> u32 { 0 }' > src/common/mandelbrot.rs && \
    echo 'pub mod common;' > src/lib.rs && \
    cargo build --release 2>/dev/null || true

# Limpiar artefactos del proyecto (mantener dependencias compiladas)
RUN rm -rf src && \
    rm -f target/release/deps/distributed_mandelbrot* && \
    rm -f target/release/deps/libdistributed_mandelbrot* && \
    rm -f target/release/worker target/release/coordinator target/release/distributed-mandelbrot && \
    rm -rf target/release/.fingerprint/distributed-mandelbrot-*

# Copiar codigo real y compilar
COPY rust/src ./src
RUN cargo build --release --bin worker

# Stage 2: Runtime
FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/worker /app/worker

ENV RUST_LOG=info
ENV WORKER_ID=worker-1
ENV COORDINATOR_URL=http://10.10.10.1:8080
ENV PORT=8081

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

CMD ["./worker"]
