/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Josip Antoliš <josip.antolis@protonmail.com>
 */

public errordomain Souschef.ServiceError {
    CANCELLED,
    UNEXPECTED_ERROR,
    FAILED_TO_CREATE_DATABASE_FILE,
    FAILED_TO_INIT_DATABASE,
    FAILED_QUERY
}
