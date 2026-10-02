# Interpretación de los gráficos

El análisis operativo completo, con capturas de Power BI, gráficos, hallazgos y recomendaciones, está en
[analisis_operativo_PowerBI.pdf](analisis_operativo_PowerBI.pdf).

Los valores salen de `consultas_reportes.sql`, ejecutado con `ADJG_analista`, y coinciden con el dashboard de Power BI.
Los ingresos consideran solo pagos con estado `Confirmado`.

## Indicadores
| Total Clientes | Total Reservas | Total Ingresos | Ticket Promedio |
|---|---|---|---|
| 53 | 102 | S/ 268,925.00 | S/ 2,636.52 |

El ticket promedio indica que cada reserva deja en promedio S/ 2,636.52 de ingreso confirmado.

## Reservas por estado
| Estado | Reservas | % |
|---|---|---|
| Completada | 36 | 35.3 |
| Pendiente | 11 | 10.8 |
| En Proceso | 10 | 9.8 |
| Parcialmente Pagada | 10 | 9.8 |
| En Espera | 6 | 5.9 |
| Cancelada | 6 | 5.9 |
| Reprogramada | 5 | 4.9 |
| Anulada | 4 | 3.9 |
| Otros (Modificada, Reembolsada, Vencida, Sobreventa, No Show, Confirmada) | 14 | 13.7 |

Solo un tercio de las reservas está completada. Hay 37 reservas abiertas (Pendiente, En Proceso, Parcialmente
Pagada y En Espera) y 18 que no llegaron a darse (Cancelada, Anulada, Reembolsada, Vencida y No Show).

## Ingresos por medio de pago
| Medio | Pagos | Ingresos | % |
|---|---|---|---|
| Visa | 30 | S/ 129,650.00 | 48.2 |
| Mastercard | 22 | S/ 59,725.00 | 22.2 |
| Transferencia Bancaria | 17 | S/ 37,725.00 | 14.0 |
| Yape | 12 | S/ 23,825.00 | 8.9 |
| Efectivo Soles | 11 | S/ 15,300.00 | 5.7 |
| Plin | 1 | S/ 2,700.00 | 1.0 |

Las tarjetas (Visa y Mastercard) concentran el 70.4 % de lo cobrado. El efectivo es el medio menos usado después de Plin.

## Reservas por fecha
| Mes | Ene | Feb | Mar | Abr | May | Jun | Jul |
|---|---|---|---|---|---|---|---|
| Reservas | 3 | 13 | 18 | 15 | 25 | 27 | 1 |

Las reservas suben desde enero y llegan al máximo en mayo y junio. Julio aparece bajo porque los datos llegan
solo hasta el 25/07/2026.

## Top 10 clientes por cantidad de reservas
Raúl Figueroa Aguilar es el cliente con más reservas (4), seguido por Adriana Ochoa Fuentes, Juan Carlos García
López, Yolanda Marín Cruz y Zacarías Navarro Reyes con 3 cada uno. Desde el sexto lugar hay muchos clientes empatados
con 2 reservas, así que el empate se resuelve por ingresos: entra el que más ha pagado. Así completan el Top 10
Luisa María Herrera Rojas, Joaquín Gutiérrez Sánchez, Isabella Rojas Torres, Emilia Ramos Díaz y Benjamín Salazar Vega.

## Ingresos por cliente
Luisa María Herrera Rojas (S/ 19,200), Joaquín Gutiérrez Sánchez (S/ 15,200) e Isabella Rojas Torres (S/ 13,900)
son los que más ingresos generan. Los clientes con más reservas no son los que más pagan: Raúl Figueroa Aguilar
tiene 4 reservas pero solo S/ 625 confirmados.
