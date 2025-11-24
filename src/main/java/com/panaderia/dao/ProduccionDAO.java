package com.panaderia.dao;

import com.panaderia.model.ProduccionItem;
import com.panaderia.util.ConexionDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class ProduccionDAO {

    private static final String INSERT_SQL =
            "INSERT INTO Produccion (id_producto, cantidad_producida, fecha) VALUES (?, ?, GETDATE())";

    public boolean registrarProduccion(List<ProduccionItem> items) {

        try (Connection conn = ConexionDB.getConnection()) {

            conn.setAutoCommit(false);
            PreparedStatement stmt = conn.prepareStatement(INSERT_SQL);

            for (ProduccionItem item : items) {
                stmt.setInt(1, item.getIdProducto());
                stmt.setInt(2, item.getCantidad());
                stmt.addBatch();
            }

            stmt.executeBatch();
            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
