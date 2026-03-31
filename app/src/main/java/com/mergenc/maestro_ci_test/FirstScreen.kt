package com.mergenc.maestro_ci_test

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.mergenc.maestro_ci_test.ui.theme.MaestrocitestTheme

@Composable
fun LoginScreen(
    email: String,
    password: String,
    showInvalidEmailDialog: Boolean,
    modifier: Modifier = Modifier,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onDismissDialog: () -> Unit,
    onContinue: () -> Unit
) {
    if (showInvalidEmailDialog) {
        AlertDialog(
            onDismissRequest = onDismissDialog,
            confirmButton = {
                TextButton(onClick = onDismissDialog) {
                    Text("Tamam")
                }
            },
            title = { Text("Hata") },
            text = { Text("Gecersiz mail adresi.") }
        )
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text(text = "Login")
        OutlinedTextField(
            value = email,
            onValueChange = onEmailChange,
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Mail") }
        )
        OutlinedTextField(
            value = password,
            onValueChange = onPasswordChange,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp),
            label = { Text("Sifre") }
        )
        Button(
            modifier = Modifier
                .padding(top = 12.dp)
                .fillMaxWidth(),
            onClick = onContinue
        ) {
            Text("Devam et")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun FirstScreenPreview() {
    MaestrocitestTheme {
        LoginScreen(
            email = "test@mail.com",
            password = "123456",
            showInvalidEmailDialog = false,
            onEmailChange = {},
            onPasswordChange = {},
            onDismissDialog = {},
            onContinue = {}
        )
    }
}
